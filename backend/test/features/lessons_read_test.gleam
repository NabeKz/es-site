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

// test: ID を指定してレッスンを取得できる
pub fn read_lesson_success_test() {
  let row = fixture_row()
  let adaptor = fn(_: uuid.Uuid) { Ok(row) }
  let expected =
    Lesson(
      id: row.id,
      name: row.name,
      instructor: row.instructor,
      starts_at: row.starts_at,
      ends_at: row.ends_at,
      capacity: row.capacity,
      remaining_slots: row.capacity - row.reserved_count,
      description: row.description,
    )

  query.read(adaptor)(uuid.v4()) |> should.equal(Ok(expected))
}

// test: 存在しない ID はエラー
pub fn read_lesson_not_found_test() {
  let adaptor = fn(_: uuid.Uuid) { Error("not found") }

  query.read(adaptor)(uuid.v4()) |> should.be_error
}
