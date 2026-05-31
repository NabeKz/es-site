import domain/member.{type MemberRecord, MemberRecord}
import generated/requests.{type AuthInput}
import generated/responses.{type Member, Member}
import gleam/result
import shared/password
import youid/uuid

pub type SaveMember =
  fn(MemberRecord) -> Result(MemberRecord, String)

pub type FindMemberByEmail =
  fn(String) -> Result(MemberRecord, String)

pub type FindMemberById =
  fn(uuid.Uuid) -> Result(MemberRecord, String)

pub type SignUp =
  fn(AuthInput) -> Result(Member, String)

pub fn signup(
  save: SaveMember,
  find: FindMemberByEmail,
  pepper: String,
) -> SignUp {
  fn(input) { do_signup(save, find, pepper, input) }
}

fn do_signup(
  save: SaveMember,
  find: FindMemberByEmail,
  pepper: String,
  input: AuthInput,
) -> Result(Member, String) {
  case find(input.email) {
    Ok(_) -> Error("email already registered")
    Error(_) -> {
      let salt = password.generate_salt()
      let hash = password.hash(input.password, salt, pepper)
      let record =
        MemberRecord(id: uuid.v4(), email: input.email, password_hash: hash, salt:)
      use saved <- result.try(save(record))
      Ok(Member(id: saved.id, email: saved.email))
    }
  }
}
