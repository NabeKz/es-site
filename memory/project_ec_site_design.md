---
type: project
title: EC サイト学習プロジェクト — 設計決定事項
updated: 2026-06-01
---

# EC サイト設計決定事項

## データモデル方針

- **イミュータブルデータモデル**を採用（リソース＋イベント分離）
- `stock` は `stock_movements` テーブルで管理（delta の SUM で現在在庫を算出）
- `payments` はイベントテーブルとして独立

## 各機能の設計

### カート

- ログイン後のみ利用可能
- `POST` は新規追加のみ（既存商品の数量増加には使わない）
- `PATCH` で数量変更

### 退会

- `withdrawn_members` テーブルで管理（Phase 2 実装予定）
- ソフトデリートではなく別テーブルで状態を表現（DB 設計方針に準拠）

## 非機能方針

- **ページネーションなし**（期間指定・LIMIT で代替。CLAUDE.md 方針に準拠）
- **バリデーション**: opaque type `ValidXxxInput` パターン、全エラー収集（`Result(a, List(String))`）

## インフラ方針

| 項目 | 採用技術 |
|------|---------|
| コンピュート | AWS ECS Fargate + ALB |
| 静的配信 | S3 + CloudFront |
| DB | Neon（PostgreSQL サーバーレス） |
| IaC | Terraform |
| コスト削減 | 不使用時は `terraform destroy` で削除 |
