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
