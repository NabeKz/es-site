---
paths:
  - "backend/src/features/**"
  - "backend/src/workflows/**"
  - "backend/test/**"
---

# 集約の整合性と Workflow

参考: [複数集約を跨ぐ処理を1つのDBトランザクションで括る前に読む記事（j5ik2o / かとじゅん）](https://zenn.dev/j5ik2o/articles/59de072b6728ff)

## 強整合と弱整合

- **強整合**: 単一集約の内部で守る不変条件。トランザクションで保護する
- **弱整合**: 複数集約にまたがるユースケース。結果整合を前提とする

| ケース | 実装 | 結果 |
|--------|------|------|
| 単一集約 | handler → feature | 同期で返す |
| 複数集約 | handler → feature（受付）→ workflow | 非同期処理 |

## 複数集約をまたぐ更新は設計のシグナル

ユースケースの実装で複数の集約を同時に更新する必要が生じたら、集約の境界が誤っている可能性を疑う。

```
# 例: 予約作成で reservations と lessons の両方を更新する必要があった
# → remaining_slots をカラムとして持つ設計が誤りだったシグナル
# → 動的に集計する設計に見直した
```

## 派生値は計算で求める

集約をまたぐ更新を避けるため、他の集約から導出できる値はカラムとして持たず、クエリ時に計算する。

- `remaining_slots = capacity - COUNT(reservations)` — `lessons` に持たない
- 予約作成時に更新が必要なカラムは存在しない → 集約が独立して更新できる

## Workflow の役割

複数集約をまたぐオーケストレーションを担う層。`features/` と並列に `workflows/` ディレクトリを置く。
弱整合で進める場合はプロセスマネージャー（workflow）を使い、失敗時は DB ロールバックではなく補償アクション（取り消しコマンド）で戻す。

```
backend/src/
├── app/
├── features/
└── workflows/
    └── withdrawal.gleam
```

## 依存の方向

```
handler → features/（イベント発行のみ）
workflow → features/ のイベント型 + コマンド（オーケストレーション）
features/ → 互いを知らない・自分のイベントを定義
```

- handler は feature だけを知る
- feature 間の依存は禁止
- 複数集約をまたぐ処理は workflow に集約

## event_queue

イベントのキューとして DB テーブルを一つ用意する。feature ごとに一時テーブルを作らず、全ワークフローで共有する。

```
app.event_queue
  id, event_type, payload, created_at
```

workflow は `event_queue` を polling して `event_type` で振り分ける。OTP のワーカープロセスと相性が良い。

**メリット**
- テーブルが一つで済む
- スケールアウトしても構造が変わらない
- レコードが残る限りリトライが自然に機能する

## イベントは状態変化に伴う

イベントは必ず集約の状態変化とセットで発行する。`event_queue` への INSERT が状態変化の記録を兼ねる。

状態変化のないイベントを発行したくなったら、モデル化できていない状態変化があるサイン。

## 非同期を前提とする

複数集約をまたぐ処理は本質的に複数のステップを踏むため、即時完了を期待しない。handler は「受け付けました」を返し、workflow が非同期で処理する。
