import features/admin_sessions/application/command
import features/admin_sessions/sql
import gleam/result
import gleam/time/timestamp
import pog
import shared/db as repo
import youid/uuid

fn do_save_session(
  db: pog.Connection,
  id: uuid.Uuid,
  admin_id: uuid.Uuid,
  token: String,
  created_at: timestamp.Timestamp,
) -> Result(String, String) {
  use _ <- repo.query(
    run: fn() { db |> sql.create_admin_session(id, admin_id, token, created_at) },
    on_error: "Failed to save admin session",
  )
  Ok(token)
}

pub fn save_session(db: pog.Connection) -> command.SaveSession {
  fn(id, admin_id, token, created_at) {
    do_save_session(db, id, admin_id, token, created_at)
  }
}

fn do_delete_session(db: pog.Connection, token: String) -> Result(Nil, String) {
  use _ <- repo.query(
    run: fn() { db |> sql.delete_admin_session(token) },
    on_error: "Failed to delete admin session",
  )
  Ok(Nil)
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
  use returned <- repo.query(
    run: fn() { db |> sql.find_admin_session_by_token(token) },
    on_error: "Failed to find admin session",
  )
  use row <- result.try(repo.first_row(
    returned,
    not_found: "admin session not found",
  ))
  Ok(row.admin_id)
}
