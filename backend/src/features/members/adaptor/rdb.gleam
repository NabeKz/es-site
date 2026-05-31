import domain/member.{type MemberRecord, MemberRecord}
import features/members/application/command
import features/members/sql
import gleam/list
import gleam/result
import gleam/string
import pog
import wisp
import youid/uuid

fn do_save(db: pog.Connection, record: MemberRecord) -> Result(MemberRecord, String) {
  db
  |> sql.create_member(
    record.id,
    record.email,
    record.password_hash,
    record.salt,
  )
  |> result.map(fn(_) { record })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save member"
  })
}

pub fn save(db: pog.Connection) -> command.SaveMember {
  do_save(db, _)
}

fn do_find_by_email(
  db: pog.Connection,
  email: String,
) -> Result(MemberRecord, String) {
  use returned <- result.try(
    db
    |> sql.find_member_by_email(email)
    |> result.map_error(fn(_) { "not found" }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  Ok(MemberRecord(
    id: row.id,
    email: row.email,
    password_hash: row.password_hash,
    salt: row.salt,
  ))
}

pub fn find_by_email(db: pog.Connection) -> command.FindMemberByEmail {
  do_find_by_email(db, _)
}

pub fn find_by_id(db: pog.Connection) -> command.FindMemberById {
  do_find_by_id(db, _)
}

fn do_find_by_id(
  db: pog.Connection,
  id: uuid.Uuid,
) -> Result(MemberRecord, String) {
  use returned <- result.try(
    db
    |> sql.find_member_by_id(id)
    |> result.map_error(fn(_) { "not found" }),
  )
  use row <- result.try(
    returned.rows
    |> list.first()
    |> result.map_error(fn(_) { "not found" }),
  )
  Ok(MemberRecord(
    id: row.id,
    email: row.email,
    password_hash: row.password_hash,
    salt: row.salt,
  ))
}
