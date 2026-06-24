// User Story: 管理者として、管理画面にログインしたい（requirements.md）

import domain/admin.{type AdminRecord, AdminRecord}
import features/admin_sessions/application/command
import generated/requests.{AuthInput}
import gleeunit/should
import shared/password
import youid/uuid

const pepper = "test-pepper"

fn fixture_admin() -> AdminRecord {
  let salt = password.generate_salt()
  let hash = password.hash("admin123", salt, pepper)
  AdminRecord(
    id: uuid.v4(),
    email: "admin@example.com",
    password_hash: hash,
    salt: salt,
  )
}

fn noop_save_session(_id, _admin_id, token, _created_at) {
  Ok(token)
}

// test: 正しいメールアドレスとパスワードでログインできる
pub fn admin_login_success_test() {
  let admin = fixture_admin()
  let find_admin = fn(_email: String) { Ok(admin) }
  let login = command.login(find_admin, noop_save_session, pepper)
  let assert Ok(#(member, _token)) =
    login(AuthInput(email: "admin@example.com", password: "admin123"))
  member.email |> should.equal("admin@example.com")
}

// test: パスワードが間違っている場合はエラー
pub fn admin_login_wrong_password_test() {
  let admin = fixture_admin()
  let find_admin = fn(_email: String) { Ok(admin) }
  let login = command.login(find_admin, noop_save_session, pepper)
  login(AuthInput(email: "admin@example.com", password: "wrong"))
  |> should.be_error
}

// test: 存在しないメールアドレスの場合はエラー
pub fn admin_login_unknown_email_test() {
  let find_admin = fn(_email: String) { Error("not found") }
  let login = command.login(find_admin, noop_save_session, pepper)
  login(AuthInput(email: "unknown@example.com", password: "admin123"))
  |> should.be_error
}
