import app/handlers/request
import app/handlers/response
import features/admin_sessions/application as admin_sessions_app
import generated/requests
import generated/responses
import wisp.{type Request, type Response}

pub const admin_session_cookie = "admin_session_token"

const admin_session_max_age = 86_400

pub type AdminAuthHandler {
  AdminAuthHandler(
    login: fn(Request) -> Response,
    logout: fn(Request) -> Response,
    me: fn(Request) -> Response,
  )
}

fn login(login_fn: admin_sessions_app.Login, req: Request) -> Response {
  use input <- request.require_json_body(req, requests.parse_auth_input)
  case login_fn(input) {
    Ok(#(admin, token)) -> {
      let res =
        admin
        |> responses.encode_member
        |> response.json_response(200)
      wisp.set_cookie(
        res,
        req,
        admin_session_cookie,
        token,
        wisp.Signed,
        admin_session_max_age,
      )
    }
    Error(_) -> wisp.response(401)
  }
}

fn logout(logout_fn: admin_sessions_app.Logout, req: Request) -> Response {
  case wisp.get_cookie(req, admin_session_cookie, wisp.Signed) {
    Ok(token) -> {
      let _ = logout_fn(token)
      wisp.no_content()
      |> wisp.set_cookie(req, admin_session_cookie, "", wisp.Signed, 0)
    }
    Error(_) -> wisp.no_content()
  }
}

fn me(me_fn: admin_sessions_app.Me, req: Request) -> Response {
  case wisp.get_cookie(req, admin_session_cookie, wisp.Signed) {
    Ok(token) ->
      case me_fn(token) {
        Ok(admin) ->
          admin
          |> responses.encode_member
          |> response.json_response(200)
        Error(_) -> wisp.response(401)
      }
    Error(_) -> wisp.response(401)
  }
}

pub fn new(
  login_fn: admin_sessions_app.Login,
  logout_fn: admin_sessions_app.Logout,
  me_fn: admin_sessions_app.Me,
) -> AdminAuthHandler {
  AdminAuthHandler(
    login: login(login_fn, _),
    logout: logout(logout_fn, _),
    me: me(me_fn, _),
  )
}
