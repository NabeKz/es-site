import gleam/http
import wisp.{type Request, type Response}

import app/handlers
import app/handlers/admin_auth
import app/handlers/auth
import app/handlers/cart
import app/handlers/orders
import app/handlers/products
import app/middleware.{middleware}

pub fn handle_request(handlers: handlers.Handlers) {
  fn(req: Request) -> Response {
    use req <- middleware(req)

    case wisp.path_segments(req) {
      ["health"] -> wisp.ok()
      ["auth", ..path] -> req |> auth_routes(path, handlers.auth)
      ["admin", ..path] ->
        req |> admin_routes(path, handlers.admin_auth, handlers.products)
      ["products", ..path] -> req |> product_routes(path, handlers.products)
      ["cart", ..path] -> req |> cart_routes(path, handlers.cart)
      ["orders", ..path] -> req |> order_routes(path, handlers.orders)
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
) -> Response {
  case path, req.method {
    ["signup"], http.Post -> req |> h.signup()
    ["login"], http.Post -> req |> h.login()
    ["logout"], http.Post -> req |> h.logout()
    ["me"], http.Get -> req |> h.me()
    _, _ -> wisp.not_found()
  }
}

pub fn admin_routes(
  req: wisp.Request,
  path: List(String),
  admin_auth_h: admin_auth.AdminAuthHandler,
  products_h: products.ProductsHandler,
) -> Response {
  case path, req.method {
    ["auth", "login"], http.Post -> req |> admin_auth_h.login()
    ["auth", "logout"], http.Post -> req |> admin_auth_h.logout()
    ["auth", "me"], http.Get -> req |> admin_auth_h.me()
    ["products"], http.Post -> req |> products_h.create()
    _, _ -> wisp.not_found()
  }
}

pub fn product_routes(
  req: wisp.Request,
  path: List(String),
  h: products.ProductsHandler,
) -> Response {
  case path, req.method {
    [], http.Get -> req |> h.list()
    _, _ -> wisp.not_found()
  }
}

pub fn cart_routes(
  req: wisp.Request,
  path: List(String),
  h: cart.CartHandler,
) -> Response {
  case path, req.method {
    ["items"], http.Post -> req |> h.add_item()
    ["items"], http.Get -> req |> h.get_items()
    ["items", id], http.Patch -> h.update_item(req, id)
    ["items", id], http.Delete -> h.delete_item(req, id)
    _, _ -> wisp.not_found()
  }
}

pub fn order_routes(
  req: wisp.Request,
  path: List(String),
  h: orders.OrdersHandler,
) -> Response {
  case path, req.method {
    [], http.Post -> req |> h.create()
    _, _ -> wisp.not_found()
  }
}
