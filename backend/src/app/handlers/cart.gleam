import app/handlers/auth.{session_cookie}
import app/handlers/error_responses
import app/handlers/request
import app/handlers/response
import app/handlers/validation
import features/cart/application as cart_app
import features/sessions/application as sessions_app
import generated/requests
import generated/responses
import gleam/json
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
  create_fn: cart_app.Create,
  find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
) -> Response {
  use member_id <- require_auth(req, find_member_id)
  use input <- request.require_json_body(
    req,
    requests.parse_add_cart_item_input,
  )
  use valid <- error_responses.require_ok(cart_app.validate(input))
  case create_fn(member_id, valid) {
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
  update_fn: cart_app.Update,
  _find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
  id: String,
) -> Response {
  use _ <- require_session(req)
  use id <- validation.require_uuid(id)
  use input <- request.require_json_body(
    req,
    requests.parse_update_cart_item_input,
  )
  use valid <- error_responses.require_ok(cart_app.validate_update(input))
  case update_fn(id, valid) {
    Ok(item) ->
      item
      |> responses.encode_cart_item
      |> response.json_response(200)
    Error(err) -> wisp.bad_request(err)
  }
}

fn delete_item(
  delete_fn: cart_app.Delete,
  _find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
  id: String,
) -> Response {
  use _ <- require_session(req)
  use id <- validation.require_uuid(id)
  case delete_fn(id) {
    Ok(_) -> wisp.no_content()
    Error(err) -> wisp.bad_request(err)
  }
}

fn get_items(
  get_items_fn: cart_app.GetCartItems,
  find_member_id: sessions_app.FindMemberIdByToken,
  req: Request,
) -> Response {
  use member_id <- require_auth(req, find_member_id)
  case get_items_fn(member_id) {
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
  find_member_id: sessions_app.FindMemberIdByToken,
  create_fn: cart_app.Create,
  update_fn: cart_app.Update,
  delete_fn: cart_app.Delete,
  get_items_fn: cart_app.GetCartItems,
) -> CartHandler {
  CartHandler(
    add_item: add_item(create_fn, find_member_id, _),
    update_item: fn(req, id) { update_item(update_fn, find_member_id, req, id) },
    delete_item: fn(req, id) { delete_item(delete_fn, find_member_id, req, id) },
    get_items: get_items(get_items_fn, find_member_id, _),
  )
}
