import features/lessons/application
import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import wisp
import youid/uuid

import features/lessons/application/command
import features/lessons/application/query.{type LessonRow, LessonRow}
import features/lessons/sql
import generated/responses.{type Lesson}

fn do_create(db: pog.Connection, lesson: Lesson) -> Result(Lesson, String) {
  db
  |> sql.create_lesson(
    lesson.id,
    lesson.name,
    lesson.instructor,
    lesson.starts_at,
    lesson.ends_at,
    lesson.capacity,
    lesson.description,
  )
  |> result.map(fn(_) { lesson })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save lesson"
  })
}

pub fn create(db: pog.Connection) -> command.SaveLesson {
  do_create(db, _)
}

fn do_read(db: pog.Connection, id: uuid.Uuid) -> Result(LessonRow, String) {
  use returned <- result.try(
    db
    |> sql.read_lesson(id)
    |> result.map_error(fn(_) { "Failed to read lesson" }),
  )

  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not unique" }),
  )

  LessonRow(
    id: row.id,
    name: row.name,
    instructor: row.instructor,
    starts_at: row.starts_at,
    ends_at: row.ends_at,
    capacity: row.capacity,
    reserved_count: row.reserved_count,
    description: row.description,
  )
  |> Ok()
}

pub fn read(db: pog.Connection) -> application.ReadAdaptor {
  do_read(db, _)
}

fn do_list(db: pog.Connection, now: timestamp.Timestamp) -> Result(List(LessonRow), String) {
  db
  |> sql.list_lesson(now)
  |> result.map(fn(r) {
    list.map(r.rows, fn(row) {
      LessonRow(
        id: row.id,
        name: row.name,
        instructor: row.instructor,
        starts_at: row.starts_at,
        ends_at: row.ends_at,
        capacity: row.capacity,
        reserved_count: row.reserved_count,
        description: row.description,
      )
    })
  })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to list lesson"
  })
}

pub fn list(db: pog.Connection) -> query.ListAdaptor {
  do_list(db, _)
}

