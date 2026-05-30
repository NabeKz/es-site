# SQL / squirrel 方針

## squirrel を使う

- DB クエリは `src/features/**/sql/*.sql` に SQL ファイルとして定義する
- `mise run gen-sql` でコードを生成し、生成された `sql.gleam` を使う
- `sql.gleam` は手動編集禁止（`gleam run -m squirrel` が上書きする）

## nullable パラメーターを避ける

- squirrel は nullable な INSERT パラメーターを生成しない
- NULL を渡したい場合は SQL ファイルを分ける
  - 例: `create_lesson.sql`（description なし）と `create_lesson_with_description.sql`
- ただし DB 設計方針（`db.md`）に従い NULL カラム自体を作らなければこの問題は発生しない

## スキーマ修飾

- テーブルは `app` スキーマに定義する
- SQL ファイル内では `app.lessons` のように明示的にスキーマを指定する
