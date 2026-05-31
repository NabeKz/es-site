import gleam/http
import wisp.{type Request, type Response}

import app/handlers
import app/handlers/auth
import app/middleware.{middleware}

pub fn handle_request(handlers: handlers.Handlers) {
  fn(req: Request) -> Response {
    use req <- middleware(req)

    case wisp.path_segments(req) {
      ["auth", ..path] -> req |> auth_routes(path, handlers.auth)
      _ -> {
        wisp.log_warning("User requested a route that does not exist")
        wisp.not_found()
      }
    }
  }
}

pub fn auth_routes(
  req: wisp.Request,
  path: List(String),
  h: auth.AuthHandler,
) {
  case path, req.method {
    ["signup"], http.Post -> req |> h.signup()
    ["login"], http.Post -> req |> h.login()
    ["logout"], http.Post -> req |> h.logout()
    ["me"], http.Get -> req |> h.me()
    _, _ -> wisp.not_found()
  }
}
