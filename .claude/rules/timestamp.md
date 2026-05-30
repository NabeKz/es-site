# タイムスタンプの扱い

## DB のカラム型

- `timestamp`（timezone なし）を使う（`timestamptz` は使わない）
- DB には UTC の値を保存する責務はアプリ側が持つ

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

## メリット

- SQL がシンプルに保てる
- DB サーバーの timezone 設定に依存しない
- テストでも任意の時刻を注入できる（テスタビリティが上がる）
