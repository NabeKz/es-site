import app/db
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/products/adaptor/rdb as products_rdb
import features/products/application as products_app
import generated/requests.{AuthInput, CreateProductInput}
import gleam/dynamic/decode
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import shared/env
import wisp
import youid/uuid

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
  let create = products_app.create(products_rdb.save(conn))

  let inputs = [
    #(
      CreateProductInput(
        name: "Gleam T-shirt",
        price: 3500,
        stock: 0,
        description: "Gleamのロゴ入りTシャツ",
      ),
      50,
    ),
    #(
      CreateProductInput(
        name: "Gleam Mug",
        price: 1500,
        stock: 0,
        description: "Gleamロゴ入りマグカップ",
      ),
      30,
    ),
    #(
      CreateProductInput(
        name: "Gleam Sticker Pack",
        price: 500,
        stock: 0,
        description: "Gleamステッカー10枚セット",
      ),
      100,
    ),
  ]

  list.each(inputs, fn(pair) {
    let #(input, initial_stock) = pair
    case products_app.validate(input) {
      Ok(valid) ->
        case create(valid) {
          Ok(product) -> {
            io.println("product created: " <> product.name)
            insert_initial_stock(conn, product.id, initial_stock)
          }
          Error(e) -> io.println("product failed: " <> e)
        }
      Error(errs) ->
        io.println("validation failed: " <> string.join(errs, ", "))
    }
  })
}

fn insert_initial_stock(
  conn: pog.Connection,
  product_id: uuid.Uuid,
  delta: Int,
) -> Nil {
  let now = timestamp.system_time()
  let _ =
    "INSERT INTO app.stock_movements (id, product_id, delta, type, created_at) VALUES ($1, $2, $3, $4, $5)"
    |> pog.query
    |> pog.parameter(pog.text(uuid.to_string(uuid.v4())))
    |> pog.parameter(pog.text(uuid.to_string(product_id)))
    |> pog.parameter(pog.int(delta))
    |> pog.parameter(pog.text("initial"))
    |> pog.parameter(pog.timestamp(now))
    |> pog.returning(decode.success(Nil))
    |> pog.execute(conn)
    |> result.map_error(fn(e) {
      io.println("stock insert failed: " <> string.inspect(e))
    })
  Nil
}
