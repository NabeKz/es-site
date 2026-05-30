# アーキテクチャ方針

## レイヤー構成

依存の方向は一方向: `app/` → `features/` → `adaptor/` → DB

- `app/` — HTTP 層。ルーティング・ミドルウェア・ハンドラー。フレームワーク依存はここに閉じ込める
- `features/<feature>/application/` — ビジネスロジック層。HTTP・DB を知らない
  - `command.gleam` — 書き込み系ユースケース（CQRS）
  - `query.gleam` — 読み取り系ユースケース（CQRS）
- `features/<feature>/adaptor/` — DB などの具体的な実装
- `features/<feature>/application.gleam` — フィーチャーの公開 API（再エクスポート）

## フィーチャーの追加

新機能は `features/<複数形>/` ディレクトリを作成し、上記の構成に従う。

## 依存性注入

関数型でアダプターを注入する。

```gleam
pub type CreateAdaptor = fn(Lesson) -> Result(Lesson, String)
pub fn create(adaptor: CreateAdaptor) -> Create { ... }
```

**組み立ては `backend.gleam` に集約する（コンポジションルート）。**
`app/` 層は `pog.Connection` などのインフラ型を知ってはいけない。

```gleam
// backend.gleam
conn |> rdb.create |> application.create |> lessons.new
```

## コード生成

- OpenAPI → `generated/requests.gleam`, `generated/responses.gleam`（手動編集禁止）
- SQL → `features/**/sql.gleam`（手動編集禁止）
- スキーマ変更は `docs/openapi.yaml` または `db/schema.hcl` を先に修正してから再生成する
