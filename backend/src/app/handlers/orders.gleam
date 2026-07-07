import app/handlers/auth.{session_cookie}
import app/handlers/response
import features/cart/adaptor/rdb as cart_rdb
import features/orders/application as orders_app
import features/orders/adaptor/rdb as orders_rdb
import features/payments/application as payments_app
import features/payments/adaptor/rdb as payments_rdb
import features/products/adaptor/rdb as products_rdb
import features/sessions/application as sessions_app
import generated/responses
import pog
import wisp.{type Request, type Response}
import workflows/orders as orders_workflow
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
  // 受付は同期で返す。在庫引き当て・決済・確定/補償はワークフローが行う（workflow.md）。
  // YAGNI: 決済モックの間は event_queue によるポーリングを作らず直接呼び出しにとどめる。
  let process =
    orders_workflow.process(
      allocate_stock: products_rdb.allocate(db),
      return_stock: products_rdb.return_stock(db),
      pay: payments_app.pay(payments_rdb.save(db)),
      confirm_order: orders_rdb.confirm(db),
      cancel_order: orders_rdb.cancel(db),
      clear_cart: cart_rdb.clear(db),
    )
  case orders_app.accept(fetch_items, save)(member_id) {
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
  db: pog.Connection,
  find_member_id: sessions_app.FindMemberIdByToken,
) -> OrdersHandler {
  OrdersHandler(create: create(db, find_member_id, _))
}
