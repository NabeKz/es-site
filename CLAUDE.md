# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

EC サイトのモノレポ。バックエンドは **Gleam (Erlang/OTP)** + **Wisp** フレームワーク、フロントエンドは **React 19** + **TanStack Router** + **Panda CSS** で構成される。

設計方針の詳細は `.claude/rules/` を参照。

## 開発コマンド

### 起動

```sh
mise run dev-all       # バックエンド・フロントエンドを同時起動
mise run dev-backend   # バックエンドのみ（port 8000）
mise run dev-frontend  # フロントエンドのみ（port 5173）
```

### バックエンド (`backend/`)

```sh
cd backend && mise run dev     # 開発サーバー（watchexec で自動再起動）
cd backend && gleam test       # 全テスト実行
cd backend && gleam test --module <module>  # 単一モジュールのテスト（例: features/lessons_create_test）
cd backend && gleam build      # ビルド確認
```

バックエンドは port **8000** で起動する。

### フロントエンド (`frontend/`)

```sh
cd frontend && pnpm dev    # 開発サーバー（port 5173）
cd frontend && pnpm build  # ビルド
cd frontend && pnpm format # フォーマット（oxfmt）
cd frontend && pnpm lint   # Lint（oxlint）
```

### コード生成

```sh
# OpenAPI + SQL 両方を生成（ルートから）
mise run codegen

# SQL のみ生成（要: ローカル DB 起動済み）
cd backend && mise run gen-sql
```

生成されるファイル（手動編集禁止）:
- `backend/src/generated/` — OpenAPI から生成した Gleam 型・バリデーション・エンコーダー
- `frontend/src/shared/generated/` — OpenAPI から生成した TypeScript fetch クライアント
- `backend/src/features/**/sql.gleam` — SQL ファイルから squirrel が生成した型安全クエリ関数
- `docs/erd.md` — `backend/db/schema.hcl` から生成した ER 図（`cd backend && mise run gen-erd`）

スキーマ変更は `docs/openapi.yaml` → `mise run codegen`、DB スキーマ変更は `backend/db/schema.hcl` → `mise run db-apply` の順で行う。

### ドキュメントの編集ルール

ドキュメントは「手書きの起点」と「生成物」を区別する。

- **手書きの起点（直接編集する）**: 仕様は `docs/requirements.md` / `docs/usecase.md`、API は `docs/openapi.yaml`、DB は `backend/db/schema.hcl`
- **生成物（編集禁止・再生成する）**: `docs/erd.md` / `generated/` / `sql.gleam`
- ドキュメントには「あるべき仕様」だけを書き、実装ステータス（抜け・TODO）は混ぜない。未達は `todo` テストで可視化する（`.claude/rules/testing.md`）
- ドキュメント同士の関係は `docs/README.md`（ドキュメントの地図）に集約する

### ローカル DB（SQL コード生成用）

squirrel は SSL 非対応のため、`gen-sql` はローカルの Docker DB を使う。

```sh
cd backend && mise run db-migrate  # Docker 起動 + スキーマ適用（Atlas）
cd backend && mise run gen-sql     # Docker 起動 + SQL → Gleam コード生成
cd backend && mise run db-seed     # スキーマ適用 + シードデータ投入
mise run db-connect                # psql で DB に接続（app スキーマ）
```

スキーマ差分の確認は `cd backend && mise run db-plan`、本番・開発 DB（Neon）への適用は `cd backend && mise run db-apply`。

### 図ツール

| 図 | ツール |
|----|--------|
| 構成図（インフラ・アーキテクチャ） | drawio（`.drawio`。SVG 書き出しは web の app.diagrams.net） |
| ユースケース図・シーケンス図 | PlantUML（`.puml`。`pumlv docs/foo.puml` でプレビュー） |
| ER 図 | Mermaid（`schema.hcl` から `mise run gen-erd` で生成・手書きしない） |

自動レイアウトの PlantUML/Mermaid は二次元自由配置の構成図に弱いので、構成図は drawio を使う。

## アーキテクチャ

### API 定義ファースト

`docs/openapi.yaml` が唯一の信頼できるソース。リクエスト/レスポンスの型・バリデーション・エンコーディングはすべてここから生成される。

### バックエンドのレイヤー構成

依存の方向は一方向: `app/` → `features/` → `adaptor/`

```
backend/src/
├── backend.gleam         # エントリーポイント。DB接続・サーバー起動
├── compose.gleam         # コンポジションルート。全フィーチャーの依存を組み立てる
├── app/
│   ├── router.gleam      # path_segments でパターンマッチするルーティング
│   ├── middleware.gleam  # ログ・CSRF 保護等
│   ├── handlers.gleam    # Handlers 構造体（全フィーチャーのハンドラーをまとめる）
│   ├── handlers/         # フィーチャー別 HTTP ハンドラー
│   └── db.gleam          # DB 接続（DATABASE_URL 環境変数）
├── features/
│   └── <feature>/
│       ├── application.gleam     # 公開 API（再エクスポート）
│       ├── application/
│       │   ├── command.gleam     # 書き込み系ユースケース（CQRS）
│       │   └── query.gleam       # 読み取り系ユースケース（CQRS）
│       ├── adaptor/
│       │   └── rdb.gleam         # DB 実装。squirrel 生成関数を呼ぶ
│       └── sql/                  # squirrel 用 SQL ファイル（1ファイル1クエリ）
├── generated/            # 自動生成（編集禁止）
└── shared/               # 共通ユーティリティ（date, env）
```

### 依存性注入パターン

アダプターを関数型で注入する。`command.gleam` はアダプター関数を受け取って `Create` 関数を返す。ハンドラーの `new(db)` でアダプターを束縛してハンドラーを組み立てる。

```gleam
pub type CreateAdaptor = fn(Entity) -> Result(Entity, String)
pub fn create(adaptor: CreateAdaptor) -> Create { ... }
```

### DB クエリ

SQL ファイル（`features/**/sql/*.sql`）を squirrel で解析してコード生成。型安全性はコード生成時（ローカル DB への接続）に検証される。

### フロントエンド構造

```
frontend/src/
├── app/routes/    # TanStack Router のファイルベースルーティング
├── pages/         # ページコンポーネント（ルートから呼ばれる）
└── shared/generated/  # 自動生成（編集禁止）
```

スタイリングは Panda CSS。`routeTree.gen.ts` と `styled-system/` は自動生成。

## 設計思想

### 整合性の厳密さはビジネス判断

リソースの整合性をどこまで厳密に守るかは技術ではなくビジネス判断。
軸は「母数（大数の法則が効くか）」と「失敗コストを定額化・補償で吸収できるか」。

- 母数が大きく損失総量が読める → 楽観的に緩めてよい（Amazon の確定者勝ち・航空券のオーバーブック）
- 母数が小さく1件が致命的 → 悲観的に厳密に守る（限定品の在庫引き当て）

実装方法（強整合/弱整合の使い分け）は `.claude/rules/consistency.md` を参照。

### 複数集約をまたぐ更新は設計のシグナル

ユースケースの実装で複数の集約を同時に更新する必要が生じたら、集約の境界が誤っている可能性を疑う。

```
# 例: 予約作成で reservations と lessons の両方を更新する必要があった
# → remaining_slots をカラムとして持つ設計が誤りだったシグナル
# → 動的に集計する設計に見直した
```

### 派生値は計算で求める

集約をまたぐ更新を避けるため、他の集約から導出できる値はカラムとして持たず、クエリ時に計算する。

- `remaining_slots = capacity - COUNT(reservations)` — `lessons` に持たない
- 予約作成時に更新が必要なカラムは存在しない → 集約が独立して更新できる

### ページネーションより制約で絞る

ページネーションは原則採用しない。大量データが必要な場合でも、期間指定（直近 X ヶ月）や LIMIT で制約をつけることで代替する。

- ページネーションの複雑性（フロントの状態管理・バックエンドのオフセットロジック）はコスパが悪い
- モダンなデバイスと回線では数千件を 1 秒未満で返せるため、件数を理由にページネーションを選ぶ必要はない
- 全件が必要なケース（CSV エクスポート等）はそもそも画面表示ではないので別途対処する
