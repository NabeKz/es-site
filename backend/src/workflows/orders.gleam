import features/cart/application as cart_app
import features/orders/application as orders_app
import features/payments/application as payments_app
import features/products/application as products_app
import gleam/result

pub type Process =
  fn(orders_app.AcceptedOrder) -> Result(Nil, String)

/// 注文処理ワークフロー（`docs/workflow.md`）。
///
/// 正常フロー: 在庫を引き当てる → 決済する → 注文を確定しカートを空にする。
/// 補償フロー: 引き当てに失敗したら取消。決済に失敗したら在庫を戻して取消。
pub fn process(
  allocate_stock allocate_stock: products_app.Allocate,
  return_stock return_stock: products_app.ReturnStock,
  pay pay: payments_app.Pay,
  confirm_order confirm_order: orders_app.ConfirmOrder,
  cancel_order cancel_order: orders_app.CancelOrder,
  clear_cart clear_cart: cart_app.ClearCart,
) -> Process {
  fn(accepted: orders_app.AcceptedOrder) {
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
