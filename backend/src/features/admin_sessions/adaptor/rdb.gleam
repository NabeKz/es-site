import features/admin_sessions/application/command
import features/admin_sessions/sql
import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import wisp
import youid/uuid

fn do_save_session(
  db: pog.Connection,
  id: uuid.Uuid,
  admin_id: uuid.Uuid,
  token: String,
  created_at: timestamp.Timestamp,
) -> Result(String, String) {
  db
  |> sql.create_admin_session(id, admin_id, token, created_at)
  |> result.map(fn(_) { token })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save admin session"
  })
}

pub fn save_session(db: pog.Connection) -> command.SaveSession {
  fn(id, admin_id, token, created_at) {
    do_save_session(db, id, admin_id, token, created_at)
  }
}

fn do_delete_session(
  db: pog.Connection,
  token: String,
) -> Result(Nil, String) {
  db
  |> sql.delete_admin_session(token)
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to delete admin session"
  })
}

pub fn delete_session(db: pog.Connection) -> command.DeleteSession {
  do_delete_session(db, _)
}

pub fn find_admin_id_by_token(db: pog.Connection) -> command.FindAdminIdByToken {
  do_find_admin_id_by_token(db, _)
}

fn do_find_admin_id_by_token(
  db: pog.Connection,
  token: String,
) -> Result(uuid.Uuid, String) {
  use returned <- result.try(
    db
    |> sql.find_admin_session_by_token(token)
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to find admin session"
    }),
  )
  returned.rows
  |> list.first()
  |> result.map(fn(row) { row.admin_id })
  |> result.map_error(fn(_) { "admin session not found" })
}
