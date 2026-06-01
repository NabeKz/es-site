import gleam/list
import gleam/result
import generated/responses.{
  type CartItem, type Order, type OrderItem, Order, OrderItem,
}
import youid/uuid.{type Uuid}

pub type FetchCartItems =
  fn(Uuid) -> Result(List(CartItem), String)

pub type SaveOrder =
  fn(Uuid, Order) -> Result(Order, String)

pub type Create =
  fn(Uuid) -> Result(Order, String)

pub fn create(fetch_items: FetchCartItems, save: SaveOrder) -> Create {
  fn(member_id: Uuid) {
    use items <- result.try(fetch_items(member_id))
    case items {
      [] -> Error("cart is empty")
      _ -> {
        let order_items = list.map(items, cart_item_to_order_item)
        let total_price =
          list.fold(order_items, 0, fn(acc, item: OrderItem) {
            acc + item.unit_price * item.quantity
          })
        let order = Order(id: uuid.v4(), items: order_items, total_price:)
        save(member_id, order)
      }
    }
  }
}

fn cart_item_to_order_item(item: CartItem) -> OrderItem {
  OrderItem(
    id: uuid.v4(),
    product_id: item.product_id,
    name: item.name,
    unit_price: item.price,
    quantity: item.quantity,
  )
}
