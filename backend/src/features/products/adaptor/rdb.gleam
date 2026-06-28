import gleam/list
import gleam/result
import gleam/time/timestamp
import pog
import youid/uuid.{type Uuid}

import features/products/application/command
import features/products/application/query
import features/products/sql
import generated/responses.{type Product}
import shared/db as repo

fn do_save(db: pog.Connection, product: Product) -> Result(Product, String) {
  use _ <- repo.query(
    run: fn() {
      db
      |> sql.create_product(
        product.id,
        product.name,
        product.price,
        product.description,
      )
    },
    on_error: "Failed to save product",
  )
  Ok(product)
}

pub fn save(db: pog.Connection) -> command.SaveProduct {
  do_save(db, _)
}

fn do_save_stock_movement(
  db: pog.Connection,
  product_id: Uuid,
  delta: Int,
  movement_type: String,
) -> Result(Nil, String) {
  let now = timestamp.system_time()
  use _ <- repo.query(
    run: fn() {
      db
      |> sql.create_stock_movement(
        uuid.v4(),
        product_id,
        delta,
        movement_type,
        now,
      )
    },
    on_error: "Failed to save stock movement",
  )
  Ok(Nil)
}

pub fn save_stock_movement(db: pog.Connection) -> command.SaveStockMovement {
  fn(product_id, delta, movement_type) {
    do_save_stock_movement(db, product_id, delta, movement_type)
  }
}

fn do_find_stock(db: pog.Connection, product_id: Uuid) -> Result(Int, String) {
  use returned <- repo.query(
    run: fn() { db |> sql.find_stock_by_product(product_id) },
    on_error: "Failed to find stock",
  )
  use row <- result.try(repo.first_row(returned, not_found: "stock not found"))
  Ok(row.stock)
}

pub fn find_stock(db: pog.Connection) -> fn(Uuid) -> Result(Int, String) {
  do_find_stock(db, _)
}

fn do_list(db: pog.Connection) -> Result(List(query.ProductRow), String) {
  use returned <- repo.query(
    run: fn() { db |> sql.list_products() },
    on_error: "Failed to list products",
  )
  Ok(
    list.map(returned.rows, fn(row) {
      query.ProductRow(
        id: row.id,
        name: row.name,
        price: row.price,
        stock: row.stock,
        description: row.description,
      )
    }),
  )
}

pub fn list(db: pog.Connection) -> query.ListAdaptor {
  fn() { do_list(db) }
}
