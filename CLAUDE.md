# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

**スポーツジム予約管理システム**のモノレポ。スタッフがレッスンスケジュールを登録し、会員がレッスン一覧確認・予約・キャンセルを行う。

バックエンドは **Gleam (Erlang/OTP)** + **Wisp** フレームワーク、フロントエンドは **React 19** + **TanStack Router** + **Panda CSS** で構成される。

設計方針の詳細は `.claude/rules/` を参照。ユースケースと要件は `docs/requirements.md` に定義されている。

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

スキーマ変更は `docs/openapi.yaml` → `mise run codegen`、DB スキーマ変更は `backend/db/schema.hcl` → `mise run db-apply` の順で行う。

### ローカル DB（SQL コード生成用）

squirrel は SSL 非対応のため、`gen-sql` はローカルの Docker DB を使う。

```sh
cd backend && mise run db-migrate  # Docker 起動 + スキーマ適用（Atlas）
cd backend && mise run gen-sql     # Docker 起動 + SQL → Gleam コード生成
cd backend && mise run db-seed     # スキーマ適用 + シードデータ投入
mise run db-connect                # psql で DB に接続（app スキーマ）
```

スキーマ差分の確認は `cd backend && mise run db-plan`、本番・開発 DB（Neon）への適用は `cd backend && mise run db-apply`。

### PlantUML ドキュメント

`docs/` に `.puml` 設計ドキュメントがある。WezTerm 上でプレビューできる。

```sh
mise run puml                          # PlantUML サーバー起動（Docker、port 8080）
mise run puml-view docs/foo.puml       # 指定ファイルをターミナルでプレビュー
mise run puml-watch docs/foo.puml      # 保存のたびに自動プレビュー
mise run puml-build                    # 全 .puml を PNG に変換
```

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

### ページネーションより制約で絞る

ページネーションは原則採用しない。大量データが必要な場合でも、期間指定（直近 X ヶ月）や LIMIT で制約をつけることで代替する。

- ページネーションの複雑性（フロントの状態管理・バックエンドのオフセットロジック）はコスパが悪い
- モダンなデバイスと回線では数千件を 1 秒未満で返せるため、件数を理由にページネーションを選ぶ必要はない
- 全件が必要なケース（CSV エクスポート等）はそもそも画面表示ではないので別途対処する
