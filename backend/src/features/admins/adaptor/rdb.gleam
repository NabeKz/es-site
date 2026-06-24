import domain/admin.{type AdminRecord, AdminRecord}
import features/admins/application/command
import features/admins/sql
import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import wisp
import youid/uuid

fn do_save(
  db: pog.Connection,
  record: AdminRecord,
  created_at: timestamp.Timestamp,
) -> Result(AdminRecord, String) {
  db
  |> sql.create_admin(
    record.id,
    record.email,
    record.password_hash,
    record.salt,
    created_at,
  )
  |> result.map(fn(_) { record })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save admin"
  })
}

pub fn save(db: pog.Connection) -> command.SaveAdmin {
  fn(record, created_at) { do_save(db, record, created_at) }
}

fn do_find_by_email(
  db: pog.Connection,
  email: String,
) -> Result(AdminRecord, String) {
  use returned <- result.try(
    db
    |> sql.find_admin_by_email(email)
    |> result.map_error(fn(_) { "not found" }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
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
  use returned <- result.try(
    db
    |> sql.find_admin_by_id(id)
    |> result.map_error(fn(_) { "not found" }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  Ok(AdminRecord(
    id: row.id,
    email: row.email,
    password_hash: row.password_hash,
    salt: row.salt,
  ))
}
