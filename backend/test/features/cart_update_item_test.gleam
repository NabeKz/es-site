// User Story: 顧客として、カート内の商品の数量を変更したい（requirements.md / UC-4）

import features/cart/application/command
import generated/requests.{UpdateCartItemInput}
import generated/responses.{type CartItem, CartItem}
import gleam/option
import gleeunit/should
import youid/uuid

fn fixture_cart_item() -> CartItem {
  CartItem(
    id: uuid.v4(),
    product_id: uuid.v4(),
    name: "テスト商品",
    price: 1000,
    quantity: 1,
  )
}

// test: 在庫数以内であれば数量を変更できる（UC-4 基本）
pub fn update_cart_item_success_test() {
  let item = fixture_cart_item()
  let assert Ok(valid) = command.validate_update(UpdateCartItemInput(quantity: 3))
  let find_item = fn(_) { Ok(option.Some(item)) }
  let find_stock = fn(_) { Ok(5) }
  let update_item = fn(_, q) { Ok(CartItem(..item, quantity: q)) }

  command.update(find_item, find_stock, update_item)(item.id, valid)
  |> should.be_ok
}

// test: 在庫数を超える数量には変更できない（UC-4 例外）
pub fn update_cart_item_exceeds_stock_test() {
  let item = fixture_cart_item()
  let assert Ok(valid) = command.validate_update(UpdateCartItemInput(quantity: 10))
  let find_item = fn(_) { Ok(option.Some(item)) }
  let find_stock = fn(_) { Ok(3) }
  let update_item = fn(_, q) { Ok(CartItem(..item, quantity: q)) }

  command.update(find_item, find_stock, update_item)(item.id, valid)
  |> should.be_error
}

// test: 対象のカートアイテムが存在しなければエラー（UC-4 例外）
pub fn update_cart_item_not_found_test() {
  let assert Ok(valid) = command.validate_update(UpdateCartItemInput(quantity: 1))
  let find_item = fn(_) { Ok(option.None) }
  let find_stock = fn(_) { Ok(5) }
  let update_item = fn(_, q) { Ok(CartItem(..fixture_cart_item(), quantity: q)) }

  command.update(find_item, find_stock, update_item)(uuid.v4(), valid)
  |> should.be_error
}
