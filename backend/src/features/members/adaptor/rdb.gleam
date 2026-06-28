import domain/member.{type MemberRecord, MemberRecord}
import features/members/application/command
import features/members/sql
import gleam/result
import pog
import shared/db as repo
import youid/uuid

fn do_save(db: pog.Connection, record: MemberRecord) -> Result(MemberRecord, String) {
  use _ <- repo.query(
    run: fn() {
      db
      |> sql.create_member(
        record.id,
        record.email,
        record.password_hash,
        record.salt,
      )
    },
    on_error: "Failed to save member",
  )
  Ok(record)
}

pub fn save(db: pog.Connection) -> command.SaveMember {
  do_save(db, _)
}

fn do_find_by_email(
  db: pog.Connection,
  email: String,
) -> Result(MemberRecord, String) {
  use returned <- repo.query(
    run: fn() { db |> sql.find_member_by_email(email) },
    on_error: "Failed to find member",
  )
  use row <- result.try(repo.first_row(returned, not_found: "not found"))
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
  use returned <- repo.query(
    run: fn() { db |> sql.find_member_by_id(id) },
    on_error: "Failed to find member",
  )
  use row <- result.try(repo.first_row(returned, not_found: "not found"))
  Ok(MemberRecord(
    id: row.id,
    email: row.email,
    password_hash: row.password_hash,
    salt: row.salt,
  ))
}
