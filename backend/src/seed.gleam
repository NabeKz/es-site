import app/db
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/products/adaptor/rdb as products_rdb
import features/products/application as products_app
import generated/requests.{AuthInput, CreateProductInput}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import pog
import shared/env
import wisp

pub fn main() {
  wisp.configure_logger()
  let conn = db.start()
  let pepper = env.get("PASSWORD_PEPPER") |> result.unwrap("")

  seed_member(conn, pepper)
  seed_products(conn)
}

fn seed_member(conn: pog.Connection, pepper: String) {
  let signup =
    members_app.signup(
      members_rdb.save(conn),
      members_rdb.find_by_email(conn),
      pepper,
    )
  let input = AuthInput(email: "test@example.com", password: "password123")
  case signup(input) {
    Ok(member) -> io.println("member created: " <> member.email)
    Error(e) -> io.println("member skipped: " <> e)
  }
}

fn seed_products(conn: pog.Connection) {
  let create =
    products_app.create(
      products_rdb.save(conn),
      products_rdb.save_stock_movement(conn),
    )

  let inputs = [
    CreateProductInput(
      name: "Gleam T-shirt",
      price: 3500,
      stock: 50,
      description: "Gleamのロゴ入りTシャツ",
    ),
    CreateProductInput(
      name: "Gleam Mug",
      price: 1500,
      stock: 30,
      description: "Gleamロゴ入りマグカップ",
    ),
    CreateProductInput(
      name: "Gleam Sticker Pack",
      price: 500,
      stock: 100,
      description: "Gleamステッカー10枚セット",
    ),
  ]

  list.each(inputs, fn(input) {
    case products_app.validate(input) {
      Ok(valid) ->
        case create(valid) {
          Ok(product) -> io.println("product created: " <> product.name)
          Error(e) -> io.println("product failed: " <> e)
        }
      Error(errs) ->
        io.println("validation failed: " <> string.join(errs, ", "))
    }
  })
}
