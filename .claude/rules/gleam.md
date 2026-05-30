# Gleam コーディング規則

## 命名

- ファイル・モジュール・関数・フィールド: スネークケース
- 型・コンストラクタ: パスカルケース
- プライベートな実装関数は `do_` プレフィックス（例: `do_create`）
- 公開関数がカリー化のラッパーで、実装は `do_` 関数に切り出す

## 型エイリアス

関数シグネチャに型エイリアスを定義して可読性を上げる。

```gleam
pub type CreateAdaptor = fn(Lesson) -> Result(Lesson, String)
pub type Create = fn(CreateLessonInput) -> Result(Lesson, String)
```

## エラーハンドリング

- 関数は `Result(a, String)` を返す
- バリデーションエラーは `Result(a, List(String))` で複数まとめて返す
- DB 固有のエラー型（`pog.QueryError`）はアダプター層で `String` に変換して上位に漏らさない
- `let assert Ok(...)` は、直前のバリデーションで保証済みの場合のみ使う

## JSON の命名変換

- Gleam 内部はスネークケース
- JSON 入出力はキャメルケース（`starts_at` ↔ `startsAt`）
- 変換は生成コード（`requests.gleam`, `responses.gleam`）が担う
