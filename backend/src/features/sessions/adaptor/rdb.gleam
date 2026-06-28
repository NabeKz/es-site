import features/sessions/application/command
import features/sessions/sql
import gleam/result
import gleam/time/timestamp
import pog
import shared/db as repo
import youid/uuid

fn do_save_session(
  db: pog.Connection,
  id: uuid.Uuid,
  member_id: uuid.Uuid,
  token: String,
  created_at: timestamp.Timestamp,
) -> Result(String, String) {
  use _ <- repo.query(
    run: fn() { db |> sql.create_session(id, member_id, token, created_at) },
    on_error: "Failed to save session",
  )
  Ok(token)
}

pub fn save_session(db: pog.Connection) -> command.SaveSession {
  fn(id, member_id, token, created_at) {
    do_save_session(db, id, member_id, token, created_at)
  }
}

fn do_delete_session(db: pog.Connection, token: String) -> Result(Nil, String) {
  use _ <- repo.query(
    run: fn() { db |> sql.delete_session(token) },
    on_error: "Failed to delete session",
  )
  Ok(Nil)
}

pub fn delete_session(db: pog.Connection) -> command.DeleteSession {
  do_delete_session(db, _)
}

pub fn find_member_id_by_token(db: pog.Connection) -> command.FindMemberIdByToken {
  do_find_member_id_by_token(db, _)
}

fn do_find_member_id_by_token(
  db: pog.Connection,
  token: String,
) -> Result(uuid.Uuid, String) {
  use returned <- repo.query(
    run: fn() { db |> sql.find_session_by_token(token) },
    on_error: "Failed to find session",
  )
  use row <- result.try(repo.first_row(returned, not_found: "session not found"))
  Ok(row.member_id)
}
