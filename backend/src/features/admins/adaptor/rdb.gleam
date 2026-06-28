import domain/admin.{type AdminRecord, AdminRecord}
import features/admins/application/command
import features/admins/sql
import gleam/result
import gleam/time/timestamp
import pog
import shared/db as repo
import youid/uuid

fn do_save(
  db: pog.Connection,
  record: AdminRecord,
  created_at: timestamp.Timestamp,
) -> Result(AdminRecord, String) {
  use _ <- repo.query(
    run: fn() {
      db
      |> sql.create_admin(
        record.id,
        record.email,
        record.password_hash,
        record.salt,
        created_at,
      )
    },
    on_error: "Failed to save admin",
  )
  Ok(record)
}

pub fn save(db: pog.Connection) -> command.SaveAdmin {
  fn(record, created_at) { do_save(db, record, created_at) }
}

fn do_find_by_email(
  db: pog.Connection,
  email: String,
) -> Result(AdminRecord, String) {
  use returned <- repo.query(
    run: fn() { db |> sql.find_admin_by_email(email) },
    on_error: "Failed to find admin",
  )
  use row <- result.try(repo.first_row(returned, not_found: "not found"))
  Ok(AdminRecord(
    id: row.id,
    email: row.email,
    password_hash: row.password_hash,
    salt: row.salt,
  ))
}

pub fn find_by_email(db: pog.Connection) -> command.FindAdminByEmail {
  do_find_by_email(db, _)
}

pub fn find_by_id(db: pog.Connection) -> command.FindAdminById {
  do_find_by_id(db, _)
}

fn do_find_by_id(
  db: pog.Connection,
  id: uuid.Uuid,
) -> Result(AdminRecord, String) {
  use returned <- repo.query(
    run: fn() { db |> sql.find_admin_by_id(id) },
    on_error: "Failed to find admin",
  )
  use row <- result.try(repo.first_row(returned, not_found: "not found"))
  Ok(AdminRecord(
    id: row.id,
    email: row.email,
    password_hash: row.password_hash,
    salt: row.salt,
  ))
}
