import app/handlers/request
import app/handlers/response
import features/members/application as members_app
import features/sessions/application as sessions_app
import generated/requests
import generated/responses
import wisp.{type Request, type Response}

pub const session_cookie = "session_token"

const session_max_age = 86_400

pub type AuthHandler {
  AuthHandler(
    signup: fn(Request) -> Response,
    login: fn(Request) -> Response,
    logout: fn(Request) -> Response,
    me: fn(Request) -> Response,
  )
}

fn signup(signup_fn: members_app.SignUp, req: Request) -> Response {
  use input <- request.require_json_body(req, requests.parse_auth_input)
  case signup_fn(input) {
    Ok(member) ->
      member
      |> responses.encode_member
      |> response.json_response(201)
    Error(err) -> wisp.bad_request(err)
  }
}

fn login(login_fn: sessions_app.Login, req: Request) -> Response {
  use input <- request.require_json_body(req, requests.parse_auth_input)
  case login_fn(input) {
    Ok(#(member, token)) -> {
      let res =
        member
        |> responses.encode_member
        |> response.json_response(200)
      wisp.set_cookie(res, req, session_cookie, token, wisp.Signed, session_max_age)
    }
    Error(_) -> wisp.response(401)
  }
}

fn logout(logout_fn: sessions_app.Logout, req: Request) -> Response {
  case wisp.get_cookie(req, session_cookie, wisp.Signed) {
    Ok(token) -> {
      let _ = logout_fn(token)
      wisp.no_content()
      |> wisp.set_cookie(req, session_cookie, "", wisp.Signed, 0)
    }
    Error(_) -> wisp.no_content()
  }
}

fn me(me_fn: sessions_app.Me, req: Request) -> Response {
  case wisp.get_cookie(req, session_cookie, wisp.Signed) {
    Ok(token) ->
      case me_fn(token) {
        Ok(member) ->
          member
          |> responses.encode_member
          |> response.json_response(200)
        Error(_) -> wisp.response(401)
      }
    Error(_) -> wisp.response(401)
  }
}

pub fn new(
  signup_fn: members_app.SignUp,
  login_fn: sessions_app.Login,
  logout_fn: sessions_app.Logout,
  me_fn: sessions_app.Me,
) -> AuthHandler {
  AuthHandler(
    signup: signup(signup_fn, _),
    login: login(login_fn, _),
    logout: logout(logout_fn, _),
    me: me(me_fn, _),
  )
}
