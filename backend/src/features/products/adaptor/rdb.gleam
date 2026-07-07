import gleam/list
import gleam/result
import gleam/time/timestamp
import pog
import youid/uuid.{type Uuid}

import features/products/application/command
import features/products/application/query
import features/products/sql
import generated/responses.{type OrderItem, type Product}
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

fn do_lock_product_stock(
  db: pog.Connection,
  product_id: Uuid,
) -> Result(Nil, String) {
  use _ <- repo.query(
    run: fn() { db |> sql.lock_product_stock(uuid.to_string(product_id)) },
    on_error: "Failed to lock product stock",
  )
  Ok(Nil)
}

/// 1商品分の在庫引き当て。呼び出し元の `pog.transaction` の中で実行される前提。
/// `product_id` 単位のアドバイザリロックで直列化してから在庫を確認するため、
/// 同じ商品への同時引き当てで売り越しが起きない。
fn do_allocate_one(
  conn: pog.Connection,
  item: OrderItem,
) -> Result(Nil, String) {
  use _ <- result.try(do_lock_product_stock(conn, item.product_id))
  use available <- result.try(do_find_stock(conn, item.product_id))
  use delta <- result.try(command.allocate_stock(
    available:,
    requested: item.quantity,
  ))
  do_save_stock_movement(conn, item.product_id, delta, "allocation")
}

fn do_allocate(db: pog.Connection, items: List(OrderItem)) -> Result(Nil, String) {
  case pog.transaction(db, fn(conn) { list.try_each(items, do_allocate_one(conn, _)) }) {
    Ok(_) -> Ok(Nil)
    Error(pog.TransactionQueryError(_)) -> Error("Failed to allocate stock")
    Error(pog.TransactionRolledBack(message)) -> Error(message)
  }
}

pub fn allocate(db: pog.Connection) -> fn(List(OrderItem)) -> Result(Nil, String) {
  fn(items) { do_allocate(db, items) }
}

/// 引き当てた在庫を戻す（決済失敗時の補償）。引き当てと違い売り越しの心配がない
/// ただの加算なので、ロックも `pog.transaction` も不要。
fn do_return_stock(db: pog.Connection, items: List(OrderItem)) -> Result(Nil, String) {
  list.try_each(items, fn(item: OrderItem) {
    do_save_stock_movement(db, item.product_id, item.quantity, "allocation_reversal")
  })
}

pub fn return_stock(db: pog.Connection) -> command.ReturnStock {
  fn(items) { do_return_stock(db, items) }
}
