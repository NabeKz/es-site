import app/handlers/admin_auth.{admin_session_cookie}
import app/handlers/error_responses
import app/handlers/request
import app/handlers/response
import features/admin_sessions/application as admin_sessions_app
import features/products/application as products_app
import generated/requests
import generated/responses
import gleam/json
import wisp.{type Request, type Response}
import youid/uuid.{type Uuid}

pub type ProductsHandler {
  ProductsHandler(
    create: fn(Request) -> Response,
    list: fn(Request) -> Response,
  )
}

fn create(
  find_admin_id: admin_sessions_app.FindAdminIdByToken,
  create_fn: products_app.Create,
  req: Request,
) -> Response {
  use admin_id <- require_admin_auth(req, find_admin_id)
  use input <- request.require_json_body(req, requests.parse_create_product_input)
  use valid <- error_responses.require_ok(products_app.validate(input))
  case create_fn(admin_id, valid) {
    Ok(product) ->
      product
      |> responses.encode_product
      |> response.json_response(201)
    Error(err) -> wisp.bad_request(err)
  }
}

fn list(list_fn: products_app.ListProducts, _req: Request) -> Response {
  case list_fn() {
    Ok(products) ->
      json.array(products, responses.encode_product)
      |> response.json_response(200)
    Error(err) -> wisp.bad_request(err)
  }
}

fn require_admin_session(
  req: Request,
  next: fn(String) -> Response,
) -> Response {
  case wisp.get_cookie(req, admin_session_cookie, wisp.Signed) {
    Ok(token) -> next(token)
    Error(_) -> wisp.response(401)
  }
}

fn require_admin_auth(
  req: Request,
  find_admin_id: admin_sessions_app.FindAdminIdByToken,
  next: fn(Uuid) -> Response,
) -> Response {
  use token <- require_admin_session(req)
  case find_admin_id(token) {
    Ok(admin_id) -> next(admin_id)
    Error(_) -> wisp.response(401)
  }
}

pub fn new(
  find_admin_id: admin_sessions_app.FindAdminIdByToken,
  create_fn: products_app.Create,
  list_fn: products_app.ListProducts,
) -> ProductsHandler {
  ProductsHandler(
    create: create(find_admin_id, create_fn, _),
    list: list(list_fn, _),
  )
}
