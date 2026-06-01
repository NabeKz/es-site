import app/handlers/error_responses
import app/handlers/request
import app/handlers/response
import features/products/application as products_app
import generated/requests
import generated/responses
import gleam/json
import wisp.{type Request, type Response}

pub type ProductsHandler {
  ProductsHandler(
    create: fn(Request) -> Response,
    list: fn(Request) -> Response,
  )
}

fn create(create_fn: products_app.Create, req: Request) -> Response {
  use input <- request.require_json_body(req, requests.parse_create_product_input)
  use valid <- error_responses.require_ok(products_app.validate(input))
  case create_fn(valid) {
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

pub fn new(
  create_fn: products_app.Create,
  list_fn: products_app.ListProducts,
) -> ProductsHandler {
  ProductsHandler(
    create: create(create_fn, _),
    list: list(list_fn, _),
  )
}
