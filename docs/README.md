# ドキュメントの地図

このリポジトリのドキュメントと、それらの依存関係（何から派生し、何を生むか）を示す。
個々の内容は各ファイルを参照。**設計方針そのものは `.claude/rules/` にある。**

## 関係図

```mermaid
flowchart TD
    req["requirements.md<br/>要件・ユーザーストーリー<br/>(手書き・起点)"]
    uc["usecase.md<br/>ユースケース記述<br/>(手書き)"]
    uc_puml["usecase.puml<br/>ユースケース図<br/>(手書き・PlantUML)"]
    wf["workflow.md<br/>ワークフロー記述<br/>(手書き)"]

    api["openapi.yaml<br/>API 定義<br/>(手書き・信頼できる唯一のソース)"]
    schema["backend/db/schema.hcl<br/>DB スキーマ<br/>(手書き・信頼できる唯一のソース)"]

    gen_be["backend/src/generated/<br/>型・検証・エンコーダー<br/>(生成・編集禁止)"]
    gen_fe["frontend/src/shared/generated/<br/>fetch クライアント<br/>(生成・編集禁止)"]
    sql_gen["features/**/sql.gleam<br/>型安全クエリ<br/>(生成・編集禁止)"]
    erd["erd.md<br/>ER 図<br/>(生成・編集禁止)"]
    db[("DB (Neon / Docker)")]

    req --> uc
    uc --> uc_puml
    uc -->|起動| wf
    uc --> api
    uc --> schema

    api -->|mise run codegen| gen_be
    api -->|mise run codegen| gen_fe
    schema -->|mise run gen-sql| sql_gen
    schema -->|mise run gen-erd| erd
    schema -->|mise run db-apply| db

    rules[".claude/rules/<br/>設計方針<br/>(手書き)"]
    rules -.governs.-> uc
    rules -.governs.-> api
    rules -.governs.-> schema

    adr["adr/<br/>設計判断の記録 (ADR)<br/>(手書き)"]
    adr -.governs.-> uc
    adr -.governs.-> schema
```

## 一覧

| ドキュメント | 役割 | 種別 | 派生元 → 派生先 |
|---|---|---|---|
| `requirements.md` | 要件・ユーザーストーリー・ビジネスルール・スコープ | 手書き（起点） | → `usecase.md` |
| `usecase.md` | ユースケース記述（基本/例外フロー・事後条件） | 手書き | `requirements.md` → `openapi.yaml` / `schema.hcl` |
| `usecase.puml` | ユースケース図（アクターと UC の関係） | 手書き（PlantUML） | `usecase.md` に追従 |
| `workflow.md` | ワークフロー記述（複数集約をまたぐ非同期処理・サーガ） | 手書き | `usecase.md`（起動）に対応 |
| `openapi.yaml` | API 定義。リクエスト/レスポンスの型・検証・エンコードの唯一のソース | 手書き | → `backend/src/generated/`・`frontend/src/shared/generated/` |
| `backend/db/schema.hcl` | DB スキーマの唯一のソース（Atlas） | 手書き | → `erd.md`・`sql.gleam`・DB |
| `erd.md` | ER 図（Mermaid） | 生成（`mise run gen-erd`） | `schema.hcl` から生成・**編集禁止** |
| `aws-architecture.drawio(.svg)` | インフラ構成図 | 手書き（drawio） | — |
| `aws-iam-cheatsheet.md` | AWS IAM 早見表 | 手書き | — |
| `bruno/` | API 動作確認用コレクション（Bruno） | 手書き | `openapi.yaml` に追従 |
| `adr/*.md` | 設計判断の記録（決定の経緯・再検討の条件） | 手書き | `usecase.md` / `schema.hcl` の設計を律する |
| `.claude/rules/*.md` | 設計方針（集約・バリデーション・SQL・DB・テスト 等） | 手書き | 上記すべての書き方を律する |

## 編集のルール

書き方・維持の方針は `CLAUDE.md`（「ドキュメントの編集ルール」「図ツール」）を参照。新しいドキュメントを足したら上記の一覧表と関係図を更新する。
</content>
