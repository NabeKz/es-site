// User Story: 顧客として、注文確定後は在庫引き当て・決済・確定/補償が自動で進んでほしい（usecase.md UC-6 / workflow.md 注文処理ワークフロー）
import features/orders/application/command
import generated/responses.{Order, OrderItem}
import gleeunit/should
import workflows/orders as workflow
import youid/uuid

fn fixture_accepted_order() -> command.AcceptedOrder {
  let order =
    Order(
      id: uuid.v4(),
      items: [
        OrderItem(
          id: uuid.v4(),
          product_id: uuid.v4(),
          name: "apple",
          unit_price: 100,
          quantity: 2,
        ),
      ],
      total_price: 200,
    )
  command.AcceptedOrder(order:, member_id: uuid.v4(), status: command.Accepted)
}

// test: 在庫が足りないとき注文を取り消す（UC-6 補償）
pub fn order_canceled_when_stock_insufficient_test() {
  let accepted = fixture_accepted_order()
  let allocate_stock = fn(_) { Error("insufficient stock") }
  let return_stock = fn(_) { panic as "in stockが足りないので在庫は戻さない" }
  let pay = fn(_, _) { panic as "引き当てに失敗したら決済しない" }
  let confirm_order = fn(_) { panic as "引き当てに失敗したら確定しない" }
  let clear_cart = fn(_) { panic as "引き当てに失敗したらカートは空にしない" }
  let cancel_order = fn(order_id) {
    case order_id == accepted.order.id {
      True -> Ok(Nil)
      False -> Error("wrong order id")
    }
  }
  workflow.process(
    allocate_stock:,
    return_stock:,
    pay:,
    confirm_order:,
    cancel_order:,
    clear_cart:,
  )(accepted)
  |> should.be_ok
}

// test: 決済が失敗したら引き当てた在庫を戻して注文を取り消す（UC-6 補償）
pub fn order_canceled_and_stock_returned_when_payment_fails_test() {
  let accepted = fixture_accepted_order()
  let allocate_stock = fn(_) { Ok(Nil) }
  let pay = fn(_, _) { Error("payment failed") }
  let confirm_order = fn(_) { panic as "決済に失敗したら確定しない" }
  let clear_cart = fn(_) { panic as "決済に失敗したらカートは空にしない" }
  let return_stock = fn(items) {
    case items == accepted.order.items {
      True -> Ok(Nil)
      False -> Error("wrong items")
    }
  }
  let cancel_order = fn(order_id) {
    case order_id == accepted.order.id {
      True -> Ok(Nil)
      False -> Error("wrong order id")
    }
  }
  workflow.process(
    allocate_stock:,
    return_stock:,
    pay:,
    confirm_order:,
    cancel_order:,
    clear_cart:,
  )(accepted)
  |> should.be_ok
}

// test: 在庫引き当てと決済が完了すると注文が確定しカートが空になる（UC-6 手順5・6）
pub fn order_confirmed_and_cart_cleared_on_success_test() {
  let accepted = fixture_accepted_order()
  let allocate_stock = fn(_) { Ok(Nil) }
  let pay = fn(_, _) { Ok(Nil) }
  let return_stock = fn(_) { panic as "成功したら在庫は戻さない" }
  let cancel_order = fn(_) { panic as "成功したら取り消さない" }
  let confirm_order = fn(order_id) {
    case order_id == accepted.order.id {
      True -> Ok(Nil)
      False -> Error("wrong order id")
    }
  }
  let clear_cart = fn(member_id) {
    case member_id == accepted.member_id {
      True -> Ok(Nil)
      False -> Error("wrong member id")
    }
  }
  workflow.process(
    allocate_stock:,
    return_stock:,
    pay:,
    confirm_order:,
    cancel_order:,
    clear_cart:,
  )(accepted)
  |> should.be_ok
}
