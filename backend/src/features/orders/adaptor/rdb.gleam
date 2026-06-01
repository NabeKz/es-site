import features/orders/application/command
import features/orders/sql
import generated/responses.{type Order, type OrderItem}
import gleam/list
import gleam/result
import gleam/string
import gleam/time/timestamp
import pog
import wisp
import youid/uuid.{type Uuid}

fn do_save(
  db: pog.Connection,
  member_id: Uuid,
  order: Order,
) -> Result(Order, String) {
  let now = timestamp.system_time()
  use _ <- result.try(
    db
    |> sql.create_order(order.id, member_id, order.total_price, now)
    |> result.map_error(fn(err) {
      wisp.log_error(string.inspect(err))
      "Failed to save order"
    }),
  )
  use _ <- result.try(
    list.try_map(order.items, fn(item: OrderItem) {
      db
      |> sql.create_order_item(
        item.id,
        order.id,
        item.product_id,
        item.name,
        item.unit_price,
        item.quantity,
      )
      |> result.map_error(fn(err) {
        wisp.log_error(string.inspect(err))
        "Failed to save order item"
      })
    }),
  )
  Ok(order)
}

pub fn save(db: pog.Connection) -> command.SaveOrder {
  fn(member_id, order) { do_save(db, member_id, order) }
}
