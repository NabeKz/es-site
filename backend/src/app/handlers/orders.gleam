import app/handlers/auth.{session_cookie}
import app/handlers/response
import features/cart/adaptor/rdb as cart_rdb
import features/orders/application as orders_app
import features/orders/adaptor/rdb as orders_rdb
import features/sessions/application as sessions_app
import generated/responses
import pog
import wisp.{type Request, type Response}
import youid/uuid.{type Uuid}

pub type OrdersHandler {
  OrdersHandler(create: fn(Request) -> Response)
}

fn create(
  db: pog.Connection,
  find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
) -> Response {
  use member_id <- require_auth(req, find_member_id)
  let fetch_items = cart_rdb.find_items_by_member(db)
  let save = orders_rdb.save(db)
  // 受付のみを同期で返す。在庫引き当て・決済・確定はワークフローが非同期で行う（workflow.md）。
  // TODO: 受付を表す 202 へ見直す（openapi /orders の 202 化と合わせて）
  case orders_app.accept(fetch_items, save)(member_id) {
    Ok(accepted) ->
      accepted.order
      |> responses.encode_order
      |> response.json_response(201)
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
  db: pog.Connection,
  find_member_id: sessions_app.FindMemberIdByToken,
) -> OrdersHandler {
  OrdersHandler(create: create(db, find_member_id, _))
}
