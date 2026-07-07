import features/cart/application/command
import features/cart/sql
import generated/responses.{type CartItem, CartItem}
import gleam/list
import gleam/option.{type Option}
import gleam/result
import pog
import shared/db as repo
import youid/uuid.{type Uuid}

fn do_save_item(
  db: pog.Connection,
  member_id: Uuid,
  item: CartItem,
) -> Result(CartItem, String) {
  use _ <- repo.query(
    run: fn() {
      db
      |> sql.save_cart_item(item.id, member_id, item.product_id, item.quantity)
    },
    on_error: "Failed to save cart item",
  )
  Ok(item)
}

pub fn save_item(db: pog.Connection) -> command.SaveCartItem {
  fn(member_id, item) { do_save_item(db, member_id, item) }
}

fn do_find_item_by_member_product(
  db: pog.Connection,
  member_id: Uuid,
  product_id: Uuid,
) -> Result(Option(CartItem), String) {
  use returned <- repo.query(
    run: fn() { db |> sql.find_cart_item_by_member_product(member_id, product_id) },
    on_error: "Failed to find cart item",
  )
  case returned.rows {
    [] -> Ok(option.None)
    [row, ..] ->
      Ok(
        option.Some(CartItem(
          id: row.id,
          product_id: row.product_id,
          name: "",
          price: 0,
          quantity: row.quantity,
        )),
      )
  }
}

pub fn find_item_by_member_product(
  db: pog.Connection,
) -> command.FindCartItem {
  fn(member_id, product_id) {
    do_find_item_by_member_product(db, member_id, product_id)
  }
}

fn do_find_items_by_member(
  db: pog.Connection,
  member_id: Uuid,
) -> Result(List(CartItem), String) {
  use returned <- repo.query(
    run: fn() { db |> sql.find_cart_items_by_member(member_id) },
    on_error: "Failed to find cart items",
  )
  Ok(
    list.map(returned.rows, fn(row) {
      CartItem(
        id: row.id,
        product_id: row.product_id,
        name: row.name,
        price: row.price,
        quantity: row.quantity,
      )
    }),
  )
}

pub fn find_items_by_member(
  db: pog.Connection,
) -> fn(Uuid) -> Result(List(CartItem), String) {
  do_find_items_by_member(db, _)
}

fn do_update_item(
  db: pog.Connection,
  id: Uuid,
  quantity: Int,
) -> Result(CartItem, String) {
  use returned <- repo.query(
    run: fn() { db |> sql.update_cart_item_quantity(id, quantity) },
    on_error: "Failed to update cart item",
  )
  use row <- result.try(repo.first_row(returned, not_found: "cart item not found"))
  Ok(CartItem(
    id: row.id,
    product_id: row.product_id,
    name: "",
    price: 0,
    quantity: row.quantity,
  ))
}

pub fn update_item(db: pog.Connection) -> command.UpdateCartItem {
  fn(id, quantity) { do_update_item(db, id, quantity) }
}

fn do_delete_item(db: pog.Connection, id: Uuid) -> Result(Nil, String) {
  use _ <- repo.query(
    run: fn() { db |> sql.delete_cart_item(id) },
    on_error: "Failed to delete cart item",
  )
  Ok(Nil)
}

pub fn delete_item(db: pog.Connection) -> command.DeleteCartItem {
  do_delete_item(db, _)
}

fn do_clear(db: pog.Connection, member_id: Uuid) -> Result(Nil, String) {
  use _ <- repo.query(
    run: fn() { db |> sql.delete_cart_items_by_member(member_id) },
    on_error: "Failed to clear cart",
  )
  Ok(Nil)
}

pub fn clear(db: pog.Connection) -> command.ClearCart {
  do_clear(db, _)
}
