import youid/uuid

import generated/requests
import generated/responses.{type Lesson, Lesson}
import gleam/order
import gleam/result
import gleam/time/timestamp

pub type SaveLesson =
  fn(Lesson) -> Result(Lesson, String)

pub type CreateLesson =
  fn(requests.CreateLessonInput) -> Result(Lesson, String)

fn check_period(
  starts_at: timestamp.Timestamp,
  ends_at: timestamp.Timestamp,
) -> Result(Nil, String) {
  case timestamp.compare(starts_at, ends_at) {
    order.Lt -> Ok(Nil)
    _ -> Error("starts_at must be before ends_at")
  }
}

fn do_create(
  adaptor: SaveLesson,
  input: requests.CreateLessonInput,
) -> Result(Lesson, String) {
  let id = uuid.v4()
  let assert Ok(starts_at) = timestamp.parse_rfc3339(input.starts_at)
  let assert Ok(ends_at) = timestamp.parse_rfc3339(input.ends_at)
  use _ <- result.try(check_period(starts_at, ends_at))
  Lesson(
    id:,
    name: input.name,
    instructor: input.instructor,
    starts_at:,
    ends_at:,
    capacity: input.capacity,
    remaining_slots: input.capacity,
    description: input.description,
  )
  |> adaptor()
}

pub fn create(adaptor: SaveLesson) -> CreateLesson {
  do_create(adaptor, _)
}
