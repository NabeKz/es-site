import app/db
import domain/admin.{AdminRecord}
import features/admins/adaptor/rdb as admins_rdb
import features/members/adaptor/rdb as members_rdb
import features/members/application as members_app
import features/products/adaptor/rdb as products_rdb
import features/products/application as products_app
import generated/requests.{AuthInput, CreateProductInput}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import shared/env
import shared/password
import wisp
import youid/uuid

pub fn main() {
  wisp.configure_logger()
  let conn = db.start()
  let pepper = env.get("PASSWORD_PEPPER") |> result.unwrap("")

  let admin_id = seed_admin(conn, pepper)
  seed_member(conn, pepper)
  seed_products(conn, admin_id)
}

fn seed_admin(conn: pog.Connection, pepper: String) -> uuid.Uuid {
  let find = admins_rdb.find_by_email(conn)
  let save = admins_rdb.save(conn)
  let email = "admin@example.com"
  case find(email) {
    Ok(existing) -> {
      io.println("admin skipped: already exists")
      existing.id
    }
    Error(_) -> {
      let salt = password.generate_salt()
      let hash = password.hash("admin123", salt, pepper)
      let record =
        AdminRecord(
          id: uuid.v4(),
          email: email,
          password_hash: hash,
          salt: salt,
        )
      case save(record, timestamp.system_time()) {
        Ok(saved) -> {
          io.println("admin created: " <> saved.email)
          saved.id
        }
        Error(e) -> panic as { "admin seed failed: " <> e }
      }
    }
  }
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

fn seed_products(conn: pog.Connection, admin_id: uuid.Uuid) {
  let create =
    products_app.create(
      uuid.v4,
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
        case create(admin_id, valid) {
          Ok(product) -> io.println("product created: " <> product.name)
          Error(e) -> io.println("product failed: " <> e)
        }
      Error(errs) ->
        io.println("validation failed: " <> string.join(errs, ", "))
    }
  })
}
