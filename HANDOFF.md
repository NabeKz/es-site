# 引き継ぎメモ

## 直近のタスク

**`adaptor/rdb.gleam` の実装（次のステップ）**

`command.gleam` / `query.gleam` の純粋関数層は完成済み。
次は DB アダプター層と SQL ファイルを実装する。

やること（TDD で進める）：

1. `backend/db/schema.hcl` に `orders` / `order_items` テーブルを追加（`cart_items` は既存確認）
2. SQL ファイルを作成（`features/**/sql/*.sql`）
3. `mise run gen-sql` でコード生成
4. `adaptor/rdb.gleam` を実装（生成コードを呼ぶだけ）
5. `handlers / router / compose` に組み込む
6. seed データ

---

## プロジェクト概要

EC サイト（学習用）。売るものは未定（汎用的な実装）。

- バックエンド: Gleam (Erlang/OTP) + Wisp（port 8000）
- フロントエンド: React 19 + TanStack Router（`frontend/`）
- 管理者フロント: 別アプリ（`admin/`、未作成）
- DB: Neon（PostgreSQL、サーバーレス）
- インフラ: AWS ECS Fargate + ALB + S3/CloudFront、Terraform で管理（未着手）

---

## 確定した設計決定

### DB 設計（イミュータブルデータモデル）

リソースとイベントを分離。

| テーブル | 種別 | 備考 |
|---|---|---|
| members | リソース | アクティブな会員のみ |
| sessions | リソース | |
| products | リソース | stock カラムなし |
| cart_items | リソース | |
| stock_movements | イベント | delta の SUM が現在在庫 |
| orders | イベント | |
| order_items | イベント | 注文時の price をスナップショット |
| payments | イベント | レコード存在 = 決済済み |

退会は `withdrawn_members` テーブルで管理（Phase 2）。

### バリデーション方針（`.claude/rules/validation.md`）

`command.gleam` に `opaque type ValidXxxInput` を定義。
`validate` を通らないと `create` に渡せない。
**全エラー収集パターン**（実装済み）。

### カート設計

- POST /cart/items: 新規追加のみ（重複は 409）
- PATCH /cart/items/{id}: 数量変更
- DELETE /cart/items/{id}: 削除
- ログイン後のみ利用可能（ゲストカートなし）

### ページネーション

採用しない。LIMIT や期間制約で代替。

---

## 実装済み

```
backend/src/features/
├── members/          ✅ ジムアプリから流用
├── sessions/         ✅ ジムアプリから流用
├── products/
│   └── application/
│       ├── command.gleam  ✅ ValidProductInput (opaque) + check_price_limit
│       └── query.gleam    ✅ ProductRow → Product
├── cart/
│   └── application/
│       └── command.gleam  ✅ ValidAddCartItemInput (opaque)
└── orders/
    └── application/
        └── command.gleam  ✅ カート取得 → 空チェック → OrderItem 生成 → 合計計算 → 保存

backend/test/features/
├── products_create_test.gleam  ✅（price バリデーション含む）
├── cart_add_item_test.gleam    ✅
└── orders_create_test.gleam   ✅（5シナリオ: 正常・スナップショット・空カート・取得エラー・保存エラー）
```

## 未実装（TDD で進める順序）

1. **各フィーチャーの rdb.gleam**（アダプター層） ← 次
2. SQL ファイル + squirrel コード生成
3. handlers / router / compose への組み込み
4. seed データ
5. フロントエンド
6. Terraform（infra/）

---

## よく使うコマンド

```sh
gleam test                        # テスト実行
gleam build                       # ビルド確認
cd /home/kazuya/workspace/ec-site/scripts && bun run gen  # OpenAPI → コード生成
cd /home/kazuya/workspace/ec-site/backend && mise run gen-sql  # SQL → Gleam コード生成
```
