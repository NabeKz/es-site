import pog

import app/handlers
import app/handlers/auth
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/sessions/adaptor/rdb as sessions_rdb
import features/sessions/application as sessions_app

pub fn build(conn: pog.Connection, pepper: String) -> handlers.Handlers {
  handlers.Handlers(
    auth: auth.new(
      members_app.signup(
        members_rdb.save(conn),
        members_rdb.find_by_email(conn),
        pepper,
      ),
      sessions_app.login(
        members_rdb.find_by_email(conn),
        sessions_rdb.save_session(conn),
        pepper,
      ),
      sessions_app.logout(sessions_rdb.delete_session(conn)),
      sessions_app.me(
        sessions_rdb.find_member_id_by_token(conn),
        members_rdb.find_by_id(conn),
      ),
    ),
  )
}
