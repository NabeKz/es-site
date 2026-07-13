---
paths:
  - "backend/src/features/**/sql/**"
  - "backend/src/features/**/sql.gleam"
  - "backend/src/features/**/adaptor/**"
  - "backend/src/features/**/application/query.gleam"
---

# SQL / クエリ層の方針

参考: 『SQLアンチパターン』Bill Karwin（スパゲッティクエリ）

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

## SQL はデータ取得に徹する

SQL にビジネスロジックを書かない。条件判断・派生値の計算・状態の解釈はアプリ層（`query.gleam`）で行う。

### CASE WHEN

基本的にアンチパターン。条件によって値を変えるのはビジネスロジック。

```sql
-- bad: キャンセル可否の判断をSQLで行う
CASE WHEN l.starts_at > NOW() THEN true ELSE false END AS cancellable
```

**例外**: N+1 を避けるための条件集計は許容する。

```sql
-- ok: 1クエリでステータス別件数を取る
COUNT(CASE WHEN status = 'active' THEN 1 END) AS active_count
```

### サブクエリ

同じ2軸で判断する。

- ビジネスロジックを表現している → アプリ層に移す
- N+1 を避けるための集計 → 許容する

```sql
-- bad: 「まだ始まっていない」という判断をサブクエリで行う
WHERE id IN (SELECT r.id FROM reservations r JOIN lessons l ON ... WHERE l.starts_at > NOW())

-- ok: 集計を1クエリで取る（COUNT と同じ動機）
(SELECT COUNT(*) FROM reservations r WHERE r.lesson_id = l.id) AS reserved_count
```

### 判断軸

| 問い | YES | NO |
|------|-----|-----|
| これを外に出したらクエリが増えるか？ | SQL に残す余地あり | アプリ層に移す |
| 条件がビジネスロジックか？ | アプリ層に移す | SQL に残す余地あり |

## 派生値の計算は query.gleam で行う

```sql
-- bad: SQL で計算
l.capacity - COUNT(r.id)::int AS remaining_slots

-- good: 生データを返す
COUNT(r.id)::int AS reserved_count
```

`remaining_slots` のような派生値は `query.gleam`（アプリケーション層）で計算する。
アダプターが返す中間型（`LessonRow` など）を `query.gleam` 内に定義し、`to_lesson` のようなマッピング関数でドメイン型に変換する。

```gleam
// query.gleam
pub type LessonRow {
  LessonRow(capacity: Int, reserved_count: Int, ...)
}

fn to_lesson(row: LessonRow) -> Lesson {
  Lesson(
    remaining_slots: row.capacity - row.reserved_count,
    ...
  )
}
```

### 各レイヤーの責務

| レイヤー | 責務 |
|----------|------|
| SQL | データの取得（集計・JOIN は OK、計算は NG） |
| `rdb.gleam` | DB 行 → 中間型（`LessonRow`）へのマッピング |
| `query.gleam` | 派生値の計算、中間型 → ドメイン型へのマッピング |

## SQL に `NOW()` を書かない

「現在時刻」が必要なクエリでは SQL に `NOW()` を書かず、アプリ側で UTC 時刻を計算してパラメーターで渡す。

```sql
-- good
WHERE starts_at > $1

-- bad: NOW() のタイムゾーンがセッション設定に依存する
WHERE starts_at > NOW()
WHERE starts_at > (NOW() AT TIME ZONE 'UTC')::timestamp
```

```gleam
// Gleam 側で now を渡す
let now = birl.utc_now() |> birl.to_erlang_datetime()
sql.get_upcoming_lessons(conn, now)
```

- SQL がシンプルに保てる
- DB サーバーの timezone 設定に依存しない
- テストでも任意の時刻を注入できる（テスタビリティが上がる）
