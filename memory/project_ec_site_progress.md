---
type: project
title: EC サイト学習プロジェクト — 実装進捗
updated: 2026-06-01
---

# EC サイト実装進捗

## 実装済み

| ファイル | 状態 |
|---------|------|
| `features/products/application/command.gleam` | 完了 |
| `features/products/application/query.gleam` | 完了 |
| `features/cart/application/command.gleam` | 完了 |
| テスト: `products_create_test` | 完了（price ≤ 100,000 バリデーション含む） |
| テスト: `cart_add_item_test` | 完了 |
| `features/orders/application/command.gleam` | 完了 |
| テスト: `orders_create_test` | 完了（5シナリオ） |

## 直近のタスク（次にやること）

1. 各フィーチャーの `adaptor/rdb.gleam`（DB アダプター層）
2. SQL ファイル + squirrel コード生成
3. handlers / router / compose への組み込み
4. seed データ

## 関連メモリ

- 設計決定事項 → [`project_ec_site_design.md`](./project_ec_site_design.md)
