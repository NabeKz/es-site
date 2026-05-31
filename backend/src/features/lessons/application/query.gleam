import generated/responses.{type Lesson, Lesson}
import gleam/list
import gleam/result
import gleam/time/timestamp.{type Timestamp}
import youid/uuid.{type Uuid}

pub type LessonRow {
  LessonRow(
    id: Uuid,
    name: String,
    instructor: String,
    starts_at: Timestamp,
    ends_at: Timestamp,
    capacity: Int,
    reserved_count: Int,
    description: String,
  )
}

pub type ListAdaptor =
  fn(Timestamp) -> Result(List(LessonRow), String)

pub type ReadAdaptor =
  fn(uuid.Uuid) -> Result(LessonRow, String)

pub type LessonList =
  fn(Timestamp) -> Result(List(Lesson), String)

pub type ReadLesson =
  fn(uuid.Uuid) -> Result(Lesson, String)

fn to_lesson(row: LessonRow) -> Lesson {
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
}

fn do_list(adaptor: ListAdaptor, now: Timestamp) -> Result(List(Lesson), String) {
  adaptor(now)
  |> result.map(list.map(_, to_lesson))
}

pub fn list(adaptor: ListAdaptor) {
  do_list(adaptor, _)
}

fn do_read(adaptor: ReadAdaptor, id: uuid.Uuid) -> Result(Lesson, String) {
  adaptor(id)
  |> result.map(to_lesson)
}

pub fn read(adaptor: ReadAdaptor) {
  do_read(adaptor, _)
}
