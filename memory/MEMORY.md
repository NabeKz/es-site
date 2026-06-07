# Memory Index

このディレクトリはプロジェクト横断の記憶ファイルを管理します。
Claude Code セッションをまたいで参照・更新されます。

## ファイル一覧

| ファイル | type | 内容 |
|---------|------|------|
| [project_ec_site_design.md](./project_ec_site_design.md) | project | EC サイトの設計決定事項（データモデル・インフラ方針） |
| [project_ec_site_progress.md](./project_ec_site_progress.md) | project | EC サイトの実装進捗・直近タスク |

## 使い方

- セッション開始時にこのファイルを読んでコンテキストを復元する
- 実装が進んだら `project_ec_site_progress.md` の進捗テーブルを更新する
- 新しい設計決定があれば `project_ec_site_design.md` に追記する
