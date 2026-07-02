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

/// 在庫引き当て（UC-6 手順4）。product 単位の不変条件 `available - requested >= 0`
/// を守り、満たせば `stock_movements` に書く在庫変動（負の delta）を返す。
///
/// この関数は純粋なので「引き当てが直列化されている」前提でのみ正しい。売り越しの
/// 実防衛は、外側で product_id 単位のアドバイザリロックにより引き当てを直列化して
/// 担保する（Amazon 方式・在庫の確保は注文確定時の1箇所だけ）。
pub fn allocate_stock(
  available available: Int,
  requested requested: Int,
) -> Result(Int, String) {
  case available >= requested {
    True -> Ok(-requested)
    False -> Error("insufficient stock")
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
