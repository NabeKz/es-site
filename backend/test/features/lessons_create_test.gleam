// User Story: スタッフとして、レッスンのスケジュールを登録したい（requirements.md）

import features/lessons/application/command
import generated/requests.{CreateLessonInput}
import generated/responses.{type Lesson}
import gleeunit/should

// test: レッスンを正常に作成できる
pub fn create_lesson_success_test() {
  let input = CreateLessonInput(
    name: "ヨガ",
    instructor: "田中",
    starts_at: "2026-05-16T10:00:00Z",
    ends_at: "2026-05-16T11:00:00Z",
    capacity: 10,
    description: "初心者向け",
  )
  let save = fn(lesson: Lesson) { Ok(lesson) }

  let assert Ok(lesson) = command.create(save)(input)

  lesson.name |> should.equal("ヨガ")
  lesson.instructor |> should.equal("田中")
  lesson.capacity |> should.equal(10)
  lesson.description |> should.equal("初心者向け")
}

// test: 作成直後の remaining_slots は capacity と同じになる
pub fn create_lesson_remaining_slots_equals_capacity_test() {
  let input = CreateLessonInput(
    name: "ヨガ",
    instructor: "田中",
    starts_at: "2026-05-16T10:00:00Z",
    ends_at: "2026-05-16T11:00:00Z",
    capacity: 5,
    description: "",
  )
  let save = fn(lesson: Lesson) { Ok(lesson) }

  let assert Ok(lesson) = command.create(save)(input)

  lesson.remaining_slots |> should.equal(lesson.capacity)
}

// test: starts_at と ends_at が同じ場合はエラー
pub fn create_lesson_starts_at_equals_ends_at_test() {
  let input = CreateLessonInput(
    name: "ヨガ",
    instructor: "田中",
    starts_at: "2026-05-16T10:00:00Z",
    ends_at: "2026-05-16T10:00:00Z",
    capacity: 10,
    description: "",
  )
  let save = fn(lesson: Lesson) { Ok(lesson) }

  command.create(save)(input) |> should.be_error
}

// test: DB エラー時は Error を返す
pub fn create_lesson_adaptor_error_test() {
  let input = CreateLessonInput(
    name: "ヨガ",
    instructor: "田中",
    starts_at: "2026-05-16T10:00:00Z",
    ends_at: "2026-05-16T11:00:00Z",
    capacity: 10,
    description: "",
  )
  let save = fn(_: Lesson) { Error("db error") }

  command.create(save)(input) |> should.be_error
}
