import features/orders/application/command.{type AcceptedOrder}
import generated/responses.{type OrderItem}
import gleam/result
import youid/uuid.{type Uuid}

/// 在庫を引き当てる（`product_id` 単位のアドバイザリロックで直列化。実機は
/// `features/orders/adaptor/rdb.gleam`）。失敗は在庫不足を意味する。
pub type AllocateStock =
  fn(List(OrderItem)) -> Result(Nil, String)

/// 引き当てた在庫を戻す（決済失敗時の補償）。
pub type ReturnStock =
  fn(List(OrderItem)) -> Result(Nil, String)

/// 決済する（モック）。
pub type Pay =
  fn(Uuid, Int) -> Result(Nil, String)

pub type ConfirmOrder =
  fn(Uuid) -> Result(Nil, String)

pub type CancelOrder =
  fn(Uuid) -> Result(Nil, String)

pub type ClearCart =
  fn(Uuid) -> Result(Nil, String)

pub type Process =
  fn(AcceptedOrder) -> Result(Nil, String)

/// 注文処理ワークフロー（`docs/workflow.md`）。
///
/// 正常フロー: 在庫を引き当てる → 決済する → 注文を確定しカートを空にする。
/// 補償フロー: 引き当てに失敗したら取消。決済に失敗したら在庫を戻して取消。
pub fn process(
  allocate_stock allocate_stock: AllocateStock,
  return_stock return_stock: ReturnStock,
  pay pay: Pay,
  confirm_order confirm_order: ConfirmOrder,
  cancel_order cancel_order: CancelOrder,
  clear_cart clear_cart: ClearCart,
) -> Process {
  fn(accepted: AcceptedOrder) {
    case allocate_stock(accepted.order.items) {
      Error(_) -> cancel_order(accepted.order.id)
      Ok(_) ->
        case pay(accepted.order.id, accepted.order.total_price) {
          Error(_) -> {
            let _ = return_stock(accepted.order.items)
            cancel_order(accepted.order.id)
          }
          Ok(_) -> {
            use _ <- result.try(confirm_order(accepted.order.id))
            clear_cart(accepted.member_id)
          }
        }
    }
  }
}
