import domain/member.{type MemberRecord}
import generated/requests.{type AuthInput}
import generated/responses.{type Member, Member}
import gleam/result
import gleam/time/timestamp
import shared/password
import youid/uuid

pub type FindMemberByEmail =
  fn(String) -> Result(MemberRecord, String)

pub type SaveSession =
  fn(uuid.Uuid, uuid.Uuid, String, timestamp.Timestamp) -> Result(String, String)

pub type DeleteSession =
  fn(String) -> Result(Nil, String)

pub type FindMemberIdByToken =
  fn(String) -> Result(uuid.Uuid, String)

pub type FindMemberById =
  fn(uuid.Uuid) -> Result(MemberRecord, String)

pub type Login =
  fn(AuthInput) -> Result(#(Member, String), String)

pub type Logout =
  fn(String) -> Result(Nil, String)

pub type Me =
  fn(String) -> Result(Member, String)

pub fn login(
  find_member: FindMemberByEmail,
  save_session: SaveSession,
  pepper: String,
) -> Login {
  fn(input) { do_login(find_member, save_session, pepper, input) }
}

fn do_login(
  find_member: FindMemberByEmail,
  save_session: SaveSession,
  pepper: String,
  input: AuthInput,
) -> Result(#(Member, String), String) {
  use record <- result.try(
    find_member(input.email)
    |> result.map_error(fn(_) { "invalid email or password" }),
  )
  case password.verify(input.password, record.salt, pepper, record.password_hash) {
    False -> Error("invalid email or password")
    True -> {
      let token =
        password.generate_salt()
        // generate_salt の乱数生成を token 生成にも流用
      let now = timestamp.system_time()
      use saved_token <- result.try(save_session(uuid.v4(), record.id, token, now))
      Ok(#(Member(id: record.id, email: record.email), saved_token))
    }
  }
}

pub fn logout(delete_session: DeleteSession) -> Logout {
  delete_session
}

pub fn me(
  find_member_id: FindMemberIdByToken,
  find_member: FindMemberById,
) -> Me {
  fn(token) {
    use member_id <- result.try(find_member_id(token))
    use record <- result.try(find_member(member_id))
    Ok(Member(id: record.id, email: record.email))
  }
}
