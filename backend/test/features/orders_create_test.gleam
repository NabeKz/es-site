// User Story: 会員として、カート内の商品を注文したい

import features/orders/application/command
import generated/responses.{type CartItem, CartItem, type Order}
import gleam/list
import gleeunit/should
import youid/uuid.{type Uuid}

fn fixture_cart_items() -> List(CartItem) {
  [
    CartItem(
      id: uuid.v4(),
      product_id: uuid.v4(),
      name: "テスト商品A",
      price: 1000,
      quantity: 2,
    ),
    CartItem(
      id: uuid.v4(),
      product_id: uuid.v4(),
      name: "テスト商品B",
      price: 500,
      quantity: 1,
    ),
  ]
}

// test: 注文が正常に作成される
pub fn create_order_success_test() {
  let member_id = uuid.v4()
  let fetch_items = fn(_: Uuid) { Ok(fixture_cart_items()) }
  let save = fn(_: Uuid, order: Order) { Ok(order) }
  let assert Ok(order) = command.create(fetch_items, save)(member_id)
  order.total_price |> should.equal(2500)
  list.length(order.items) |> should.equal(2)
}

// test: OrderItem に商品のスナップショット価格が入る
pub fn create_order_snapshots_unit_price_test() {
  let member_id = uuid.v4()
  let fetch_items = fn(_: Uuid) { Ok(fixture_cart_items()) }
  let save = fn(_: Uuid, order: Order) { Ok(order) }
  let assert Ok(order) = command.create(fetch_items, save)(member_id)
  let assert Ok(first) = list.first(order.items)
  first.unit_price |> should.equal(1000)
  first.quantity |> should.equal(2)
}

// test: カートが空のときはエラー
pub fn create_order_empty_cart_test() {
  let member_id = uuid.v4()
  let fetch_items = fn(_: Uuid) { Ok([]) }
  let save = fn(_: Uuid, order: Order) { Ok(order) }
  command.create(fetch_items, save)(member_id) |> should.be_error
}

// test: カート取得でエラーが起きたらエラーを返す
pub fn create_order_fetch_error_test() {
  let member_id = uuid.v4()
  let fetch_items = fn(_: Uuid) { Error("db error") }
  let save = fn(_: Uuid, order: Order) { Ok(order) }
  command.create(fetch_items, save)(member_id) |> should.be_error
}

// test: 保存でエラーが起きたらエラーを返す
pub fn create_order_save_error_test() {
  let member_id = uuid.v4()
  let fetch_items = fn(_: Uuid) { Ok(fixture_cart_items()) }
  let save = fn(_: Uuid, _: Order) { Error("db error") }
  command.create(fetch_items, save)(member_id) |> should.be_error
}

// --- 以下はサーガ設計（UC-6: 受付 → 在庫引き当て・決済 → 確定 / 失敗時は補償）の観点。
//     実装フェーズで上の同期版テストをこの形に再構成する ---

// test: 注文を受け付けると「受付」状態になる（UC-6 受付）
pub fn accept_order_marks_pending_test() {
  todo
  // カートに商品があれば注文を受け付け、状態が「受付」になる
}

// test: 在庫を引き当てるとき同じ商品を売り越さない（UC-6 手順4）
pub fn allocate_stock_prevents_overselling_test() {
  todo
  // 在庫が注文数を満たせば引き当て成功、満たさなければ失敗する（単一集約の不変条件）
}

// test: 在庫が足りないとき注文を取り消す（UC-6 補償）
pub fn order_canceled_when_stock_insufficient_test() {
  todo
  // 引き当てに失敗したら注文の状態が「取消」になる
}

// test: 決済が失敗したら引き当てた在庫を戻して注文を取り消す（UC-6 補償）
pub fn order_canceled_and_stock_returned_when_payment_fails_test() {
  todo
  // 決済失敗時、引き当てた在庫を戻し、注文の状態が「取消」になる
}

// test: 在庫引き当てと決済が完了すると注文が確定しカートが空になる（UC-6 手順5・6）
pub fn order_confirmed_and_cart_cleared_on_success_test() {
  todo
  // 引き当てと決済が成功したら注文の状態が「確定」になり、カートが空になる
}
