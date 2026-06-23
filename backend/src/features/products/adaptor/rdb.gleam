import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import wisp
import youid/uuid.{type Uuid}

import features/products/application/command
import features/products/application/query
import features/products/sql
import generated/responses.{type Product}

fn do_save(db: pog.Connection, product: Product) -> Result(Product, String) {
  db
  |> sql.create_product(
    product.id,
    product.name,
    product.price,
    product.description,
  )
  |> result.map(fn(_) { product })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save product"
  })
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
  db
  |> sql.create_stock_movement(uuid.v4(), product_id, delta, movement_type, now)
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(err) {
    wisp.log_error(string.inspect(err))
    "Failed to save stock movement"
  })
}

pub fn save_stock_movement(db: pog.Connection) -> command.SaveStockMovement {
  fn(product_id, delta, movement_type) {
    do_save_stock_movement(db, product_id, delta, movement_type)
  }
}

fn do_find_stock(db: pog.Connection, product_id: Uuid) -> Result(Int, String) {
  use returned <- result.try(
    db
    |> sql.find_stock_by_product(product_id)
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to find stock"
    }),
  )
  returned.rows
  |> list.first()
  |> result.map(fn(row) { row.stock })
  |> result.map_error(fn(_) { "stock not found" })
}

pub fn find_stock(db: pog.Connection) -> fn(Uuid) -> Result(Int, String) {
  do_find_stock(db, _)
}

fn do_list(db: pog.Connection) -> Result(List(query.ProductRow), String) {
  use returned <- result.try(
    db
    |> sql.list_products()
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to list products"
    }),
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
