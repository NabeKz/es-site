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
/// 非同期で遷移させる。
pub type AcceptedOrder {
  AcceptedOrder(order: Order, status: OrderStatus)
}

pub type FetchCartItems =
  fn(Uuid) -> Result(List(CartItem), String)

pub type SaveOrder =
  fn(Uuid, Order) -> Result(Order, String)

pub type Accept =
  fn(Uuid) -> Result(AcceptedOrder, String)

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
        AcceptedOrder(order: saved, status: Accepted)
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
