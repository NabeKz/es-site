import gleam/list
import gleam/result
import gleam/string
import pog
import wisp
import youid/uuid

import features/reservations/application/command
import features/reservations/application/query
import features/reservations/sql
import generated/responses.{type Reservation, Reservation}

pub fn create(db: pog.Connection) -> command.SaveReservation {
  do_create(db, _)
}

fn do_create(
  db: pog.Connection,
  info: command.ReservationInfo,
) -> Result(Reservation, String) {
  use returned <- result.try(
    db
    |> sql.create_reservation(info.id, info.lesson_id, info.member_id)
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to save reservation"
    }),
  )
  case returned.rows {
    [_] -> Ok(Reservation(id: info.id, lesson_id: info.lesson_id))
    _ -> Error("no remaining slots")
  }
}

pub fn list_my_reservations(db: pog.Connection) -> query.ListMyReservationsAdaptor {
  do_list_my_reservations(db, _)
}

fn do_list_my_reservations(
  db: pog.Connection,
  member_id: uuid.Uuid,
) -> Result(List(Reservation), String) {
  use returned <- result.try(
    db
    |> sql.list_my_reservations(member_id)
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to list reservations"
    }),
  )
  returned.rows
  |> list.map(fn(row) { Reservation(id: row.id, lesson_id: row.lesson_id) })
  |> Ok()
}

pub fn read_reservation_info(db: pog.Connection) -> command.ReadReservationInfo {
  do_read_reservation_info(db, _)
}

fn do_read_reservation_info(
  db: pog.Connection,
  id: uuid.Uuid,
) -> Result(command.ReservationInfo, String) {
  use returned <- result.try(
    db
    |> sql.read_reservation_info(id)
    |> result.map_error(fn(_) { "Failed to read reservation" }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  command.ReservationInfo(id: row.id, lesson_id: row.lesson_id, member_id: row.member_id)
  |> Ok()
}

pub fn delete_reservation(db: pog.Connection) -> command.DeleteReservation {
  do_delete_reservation(db, _)
}

fn do_delete_reservation(db: pog.Connection, id: uuid.Uuid) -> Result(Nil, String) {
  db
  |> sql.delete_reservation(id)
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to delete reservation"
  })
}

