# Workflow 設計方針

## 単一集約 vs 複数集約

| ケース | 実装 | 結果 |
|--------|------|------|
| 単一集約 | handler → feature | 同期で返す |
| 複数集約 | handler → feature（受付）→ workflow | 非同期処理 |

## Workflow の役割

複数集約をまたぐオーケストレーションを担う層。`features/` と並列に `workflows/` ディレクトリを置く。

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
