import gleam/list
import gleam/result
import generated/responses.{
  type CartItem, type Order, type OrderItem, Order, OrderItem,
}
import youid/uuid.{type Uuid}

/// 注文の状態（UC-6 / workflow.md）。受付 → 確定（成功）／取消（失敗）と遷移する。
/// DB では状態ごとに別テーブルで表現する（db.md）が、ドメインでは 1 つの型で扱う。
pub type OrderStatus {
  Accepted
  Confirmed
  Canceled
}

/// 受け付けられた注文。受付時点では常に `Accepted`。確定・取消は注文処理ワークフローが
/// 非同期で遷移させる。`member_id` は確定後のカートクリアに使う。
pub type AcceptedOrder {
  AcceptedOrder(order: Order, member_id: Uuid, status: OrderStatus)
}

pub type FetchCartItems =
  fn(Uuid) -> Result(List(CartItem), String)

pub type SaveOrder =
  fn(Uuid, Order) -> Result(Order, String)

pub type Accept =
  fn(Uuid) -> Result(AcceptedOrder, String)

/// 注文を確定する（UC-6 手順5）。`order_confirmations` への記録で表現する（db.md）。
pub type ConfirmOrder =
  fn(Uuid) -> Result(Nil, String)

/// 注文を取り消す（UC-6 補償）。`order_cancellations` への記録で表現する（db.md）。
pub type CancelOrder =
  fn(Uuid) -> Result(Nil, String)

/// 注文を受け付ける（UC-6 受付）。カートに商品があれば注文を「受付」状態で作成する。
/// 在庫引き当て・決済・確定／補償は受付後にワークフローが非同期で行う（workflow.md）。
/// 例外はカートが空のときのみ。
pub fn accept(fetch_items: FetchCartItems, save: SaveOrder) -> Accept {
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
        use saved <- result.map(save(member_id, order))
        AcceptedOrder(order: saved, member_id:, status: Accepted)
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
