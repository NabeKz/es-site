# SQL の複雑さの判断基準

参考: 『SQLアンチパターン』Bill Karwin（スパゲッティクエリ）

## 原則: SQL はデータ取得に徹する

SQL にビジネスロジックを書かない。条件判断・派生値の計算・状態の解釈はアプリ層（`query.gleam`）で行う。

## CASE WHEN

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

## サブクエリ

同じ2軸で判断する。

- ビジネスロジックを表現している → アプリ層に移す
- N+1 を避けるための集計 → 許容する

```sql
-- bad: 「まだ始まっていない」という判断をサブクエリで行う
WHERE id IN (SELECT r.id FROM reservations r JOIN lessons l ON ... WHERE l.starts_at > NOW())

-- ok: 集計を1クエリで取る（COUNT と同じ動機）
(SELECT COUNT(*) FROM reservations r WHERE r.lesson_id = l.id) AS reserved_count
```

## 判断軸

| 問い | YES | NO |
|------|-----|-----|
| これを外に出したらクエリが増えるか？ | SQL に残す余地あり | アプリ層に移す |
| 条件がビジネスロジックか？ | アプリ層に移す | SQL に残す余地あり |
