// User Story: 会員として、開催予定のレッスン一覧を空き状況付きで確認したい（requirements.md）

import features/lessons/application/query
import generated/responses.{Lesson}
import gleam/time/timestamp
import gleeunit/should
import youid/uuid

fn fixture_row() -> query.LessonRow {
  let assert Ok(starts_at) = timestamp.parse_rfc3339("2026-05-16T10:00:00Z")
  let assert Ok(ends_at) = timestamp.parse_rfc3339("2026-05-16T11:00:00Z")
  query.LessonRow(
    id: uuid.v4(),
    name: "ヨガ",
    instructor: "田中",
    starts_at:,
    ends_at:,
    capacity: 10,
    reserved_count: 2,
    description: "",
  )
}

fn fixture_now() -> timestamp.Timestamp {
  let assert Ok(now) = timestamp.parse_rfc3339("2026-05-16T09:00:00Z")
  now
}

// test: 開催前のレッスン一覧を取得できる
pub fn list_lessons_success_test() {
  let row = fixture_row()
  let adaptor = fn(_: timestamp.Timestamp) { Ok([row]) }
  let expected = [
    Lesson(
      id: row.id,
      name: row.name,
      instructor: row.instructor,
      starts_at: row.starts_at,
      ends_at: row.ends_at,
      capacity: row.capacity,
      remaining_slots: row.capacity - row.reserved_count,
      description: row.description,
    ),
  ]

  query.list(adaptor)(fixture_now()) |> should.equal(Ok(expected))
}

// test: 開催前のレッスンがない場合は空リストを返す
pub fn list_lessons_empty_test() {
  let adaptor = fn(_: timestamp.Timestamp) { Ok([]) }

  query.list(adaptor)(fixture_now()) |> should.equal(Ok([]))
}

// test: DB エラー時は Error を返す
pub fn list_lessons_adaptor_error_test() {
  let adaptor = fn(_: timestamp.Timestamp) { Error("db error") }

  query.list(adaptor)(fixture_now()) |> should.be_error
}
