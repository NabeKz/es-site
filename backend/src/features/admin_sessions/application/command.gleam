import domain/admin.{type AdminRecord}
import generated/requests.{type AuthInput}
import generated/responses.{type Member, Member}
import gleam/result
import gleam/time/timestamp
import shared/password
import youid/uuid

pub type FindAdminByEmail =
  fn(String) -> Result(AdminRecord, String)

pub type SaveSession =
  fn(uuid.Uuid, uuid.Uuid, String, timestamp.Timestamp) -> Result(String, String)

pub type DeleteSession =
  fn(String) -> Result(Nil, String)

pub type FindAdminIdByToken =
  fn(String) -> Result(uuid.Uuid, String)

pub type FindAdminById =
  fn(uuid.Uuid) -> Result(AdminRecord, String)

// Admin の応答型は Member と同じ形（id + email）なので流用する
// OpenAPI に Admin スキーマ追加 + codegen 後に切り替え
pub type Login =
  fn(AuthInput) -> Result(#(Member, String), String)

pub type Logout =
  fn(String) -> Result(Nil, String)

pub type Me =
  fn(String) -> Result(Member, String)

pub fn login(
  find_admin: FindAdminByEmail,
  save_session: SaveSession,
  pepper: String,
) -> Login {
  fn(input) { do_login(find_admin, save_session, pepper, input) }
}

fn do_login(
  find_admin: FindAdminByEmail,
  save_session: SaveSession,
  pepper: String,
  input: AuthInput,
) -> Result(#(Member, String), String) {
  use record <- result.try(
    find_admin(input.email)
    |> result.map_error(fn(_) { "invalid email or password" }),
  )
  case password.verify(input.password, record.salt, pepper, record.password_hash) {
    False -> Error("invalid email or password")
    True -> {
      let token = password.generate_salt()
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
  find_admin_id: FindAdminIdByToken,
  find_admin: FindAdminById,
) -> Me {
  fn(token) {
    use admin_id <- result.try(find_admin_id(token))
    use record <- result.try(find_admin(admin_id))
    Ok(Member(id: record.id, email: record.email))
  }
}
