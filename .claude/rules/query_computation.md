# クエリ層での計算

## SQL は生データを返す

SQL ファイルはデータの取得のみを担う。派生値の計算は SQL に書かない。

```sql
-- bad: SQL で計算
l.capacity - COUNT(r.id)::int AS remaining_slots

-- good: 生データを返す
COUNT(r.id)::int AS reserved_count
```

## 計算は query.gleam で行う

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

## 各レイヤーの責務

| レイヤー | 責務 |
|----------|------|
| SQL | データの取得（集計・JOIN は OK、計算は NG） |
| `rdb.gleam` | DB 行 → 中間型（`LessonRow`）へのマッピング |
| `query.gleam` | 派生値の計算、中間型 → ドメイン型へのマッピング |
