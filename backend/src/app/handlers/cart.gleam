import app/handlers/auth.{session_cookie}
import app/handlers/error_responses
import app/handlers/request
import app/handlers/response
import app/handlers/validation
import features/cart/application as cart_app
import features/cart/adaptor/rdb as cart_rdb
import features/products/adaptor/rdb as products_rdb
import features/sessions/application as sessions_app
import generated/requests
import generated/responses
import gleam/json
import pog
import wisp.{type Request, type Response}
import youid/uuid.{type Uuid}

pub type CartHandler {
  CartHandler(
    add_item: fn(Request) -> Response,
    update_item: fn(Request, String) -> Response,
    delete_item: fn(Request, String) -> Response,
    get_items: fn(Request) -> Response,
  )
}

fn add_item(
  db: pog.Connection,
  find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
) -> Response {
  use member_id <- require_auth(req, find_member_id)
  use input <- request.require_json_body(req, requests.parse_add_cart_item_input)
  use valid <- error_responses.require_ok(cart_app.validate(input))
  let save = cart_rdb.save_item(db)
  let find_stock = products_rdb.find_stock(db)
  let find_item = cart_rdb.find_item_by_member_product(db)
  case cart_app.create(save, find_stock, find_item)(member_id, valid) {
    Ok(item) ->
      item
      |> responses.encode_cart_item
      |> response.json_response(201)
    Error("already in cart") -> wisp.response(409)
    Error("out of stock") -> wisp.response(409)
    Error(err) -> wisp.bad_request(err)
  }
}

fn update_item(
  db: pog.Connection,
  _find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
  id: String,
) -> Response {
  use _ <- require_session(req)
  use id <- validation.require_uuid(id)
  use input <- request.require_json_body(req, requests.parse_update_cart_item_input)
  use valid <- error_responses.require_ok(cart_app.validate_update(input))
  case cart_app.update(cart_rdb.update_item(db))(id, valid) {
    Ok(item) ->
      item
      |> responses.encode_cart_item
      |> response.json_response(200)
    Error(err) -> wisp.bad_request(err)
  }
}

fn delete_item(
  db: pog.Connection,
  _find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
  id: String,
) -> Response {
  use _ <- require_session(req)
  use id <- validation.require_uuid(id)
  case cart_app.delete(cart_rdb.delete_item(db))(id) {
    Ok(_) -> wisp.no_content()
    Error(err) -> wisp.bad_request(err)
  }
}

fn get_items(
  db: pog.Connection,
  find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
) -> Response {
  use member_id <- require_auth(req, find_member_id)
  case cart_rdb.find_items_by_member(db)(member_id) {
    Ok(items) ->
      json.array(items, responses.encode_cart_item)
      |> response.json_response(200)
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
) -> CartHandler {
  CartHandler(
    add_item: add_item(db, find_member_id, _),
    update_item: fn(req, id) { update_item(db, find_member_id, req, id) },
    delete_item: fn(req, id) { delete_item(db, find_member_id, req, id) },
    get_items: get_items(db, find_member_id, _),
  )
}
