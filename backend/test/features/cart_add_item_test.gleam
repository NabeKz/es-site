// User Story: 顧客として、商品をカートに追加したい（requirements.md）

import features/cart/application/command
import generated/requests.{type AddCartItemInput, AddCartItemInput}
import generated/responses.{type CartItem, CartItem}
import gleam/option
import gleeunit/should
import youid/uuid

fn fixture_input() -> AddCartItemInput {
  AddCartItemInput(product_id: uuid.v4(), quantity: 2)
}

fn fixture_cart_item(input: AddCartItemInput) -> CartItem {
  CartItem(
    id: uuid.v4(),
    product_id: input.product_id,
    name: "テスト商品",
    price: 1000,
    quantity: input.quantity,
  )
}

// test: 在庫が0の場合はカートに追加できない
pub fn add_cart_item_out_of_stock_test() {
  let input = fixture_input()
  let assert Ok(valid) = command.validate(input)
  let find_stock = fn(_) { Ok(0) }
  let find_cart_item = fn(_, _) { Ok(option.None) }
  let save = fn(item: CartItem) { Ok(item) }

  command.create(save, find_stock, find_cart_item)(uuid.v4(), valid)
  |> should.be_error
}

// test: 同じ商品がすでにカートにある場合はエラー
pub fn add_cart_item_duplicate_test() {
  let input = fixture_input()
  let assert Ok(valid) = command.validate(input)
  let find_stock = fn(_) { Ok(10) }
  let find_cart_item = fn(_, _) { Ok(option.Some(fixture_cart_item(input))) }
  let save = fn(item: CartItem) { Ok(item) }

  command.create(save, find_stock, find_cart_item)(uuid.v4(), valid)
  |> should.be_error
}

// test: DB エラー時はエラーを返す
pub fn add_cart_item_adaptor_error_test() {
  let assert Ok(valid) = command.validate(fixture_input())
  let find_stock = fn(_) { Ok(10) }
  let find_cart_item = fn(_, _) { Ok(option.None) }
  let save = fn(_: CartItem) { Error("db error") }

  command.create(save, find_stock, find_cart_item)(uuid.v4(), valid)
  |> should.be_error
}
