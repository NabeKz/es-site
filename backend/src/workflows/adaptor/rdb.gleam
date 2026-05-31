import gleam/list
import gleam/result
import gleam/string
import pog
import wisp
import youid/uuid.{type Uuid}

import features/lessons/sql as lessons_sql
import features/reservations/sql as reservations_sql
import generated/responses.{type Reservation, Reservation}
import workflows/create_reservation

pub fn get_lesson(conn: pog.Connection) -> create_reservation.GetLesson {
  do_get_lesson(conn, _)
}

pub fn has_reservation(conn: pog.Connection) -> create_reservation.HasReservation {
  fn(lesson_id, member_id) { do_has_reservation(conn, lesson_id, member_id) }
}

pub fn save_reservation(conn: pog.Connection) -> create_reservation.SaveReservation {
  do_save(conn, _)
}

fn do_get_lesson(
  conn: pog.Connection,
  id: Uuid,
) -> Result(create_reservation.LessonInfo, String) {
  use returned <- result.try(
    conn
    |> lessons_sql.read_lesson_capacity(id)
    |> result.map_error(fn(e) {
      wisp.log_error(string.inspect(e))
      "Failed to read lesson"
    }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  Ok(create_reservation.LessonInfo(
    capacity: row.capacity,
    reserved_count: row.reserved_count,
  ))
}

fn do_has_reservation(
  conn: pog.Connection,
  lesson_id: Uuid,
  member_id: Uuid,
) -> Result(Bool, String) {
  conn
  |> reservations_sql.read_member_reservation(lesson_id, member_id)
  |> result.map(fn(returned) { !list.is_empty(returned.rows) })
  |> result.map_error(fn(e) {
    wisp.log_error(string.inspect(e))
    "Failed to check reservation"
  })
}

fn do_save(
  conn: pog.Connection,
  info: create_reservation.ReservationInfo,
) -> Result(Reservation, String) {
  conn
  |> reservations_sql.create_reservation(info.id, info.lesson_id, info.member_id)
  |> result.map(fn(_) { Reservation(id: info.id, lesson_id: info.lesson_id) })
  |> result.map_error(fn(e) {
    wisp.log_error(string.inspect(e))
    "Failed to create reservation"
  })
}
