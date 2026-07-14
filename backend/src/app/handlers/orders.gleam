import app/handlers/auth.{session_cookie}
import app/handlers/response
import features/orders/application as orders_app
import features/sessions/application as sessions_app
import generated/responses
import wisp.{type Request, type Response}
import workflows/orders as orders_workflow
import youid/uuid.{type Uuid}

pub type OrdersHandler {
  OrdersHandler(create: fn(Request) -> Response)
}

fn create(
  accept_fn: orders_app.Accept,
  process: orders_workflow.Process,
  find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
) -> Response {
  use member_id <- require_auth(req, find_member_id)
  case accept_fn(member_id) {
    Ok(accepted) -> {
      let _ = process(accepted)
      accepted.order
      |> responses.encode_order
      |> response.json_response(202)
    }
    Error("cart is empty") -> wisp.response(422)
    Error(err) -> wisp.bad_request(err)
  }
}

fn require_session(req: Request, next: fn(String) -> Response) -> Response {
  case wisp.get_cookie(req, session_cookie, wisp.Signed) {
    Ok(token) -> next(token)
    Error(_) -> wisp.response(401)
  }
}

fn require_auth(
  req: Request,
  find_member_id: sessions_app.FindMemberIdByToken,
  next: fn(Uuid) -> Response,
) -> Response {
  use token <- require_session(req)
  case find_member_id(token) {
    Ok(member_id) -> next(member_id)
    Error(_) -> wisp.response(401)
  }
}

pub fn new(
  find_member_id: sessions_app.FindMemberIdByToken,
  accept_fn: orders_app.Accept,
  process: orders_workflow.Process,
) -> OrdersHandler {
  OrdersHandler(create: create(accept_fn, process, find_member_id, _))
}
