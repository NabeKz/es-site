// User Story: 管理者として、商品を登録したい（requirements.md）

import features/products/application/command
import generated/requests.{type CreateProductInput, CreateProductInput}
import generated/responses.{type Product}
import gleeunit/should

fn fixture_input() -> CreateProductInput {
  CreateProductInput(
    name: "テスト商品",
    price: 1000,
    stock: 10,
    description: "テスト用の商品です",
  )
}

fn noop_save_movement(_product_id, _delta, _type) {
  Ok(Nil)
}

// test: DB エラー時は Error を返す
pub fn create_product_adaptor_error_test() {
  let assert Ok(valid) = command.validate(fixture_input())
  let save = fn(_: Product) { Error("db error") }
  command.create(save, noop_save_movement)(valid) |> should.be_error
}

// test: 価格の上限を超えたらエラー
pub fn create_product_price_too_high_test() {
  let input = CreateProductInput(..fixture_input(), price: 100_001)
  command.validate(input) |> should.be_error
}

// test: 商品登録時に初期在庫が stock_movements に記録される（UC-1 手順4）
pub fn create_product_records_initial_stock_test() {
  let assert Ok(valid) = command.validate(fixture_input())
  let save = fn(product: Product) { Ok(product) }
  let save_movement = fn(_product_id, delta, movement_type) {
    delta |> should.equal(10)
    movement_type |> should.equal("initial")
    Ok(Nil)
  }
  let assert Ok(product) = command.create(save, save_movement)(valid)
  product.stock |> should.equal(10)
}

// test: 初期在庫が0のときは stock_movement を記録しない
pub fn create_product_zero_stock_no_movement_test() {
  let input = CreateProductInput(..fixture_input(), stock: 0)
  let assert Ok(valid) = command.validate(input)
  let save = fn(product: Product) { Ok(product) }
  let save_movement = fn(_product_id, _delta, _type) {
    panic as "stock_movement should not be saved when stock is 0"
  }
  let assert Ok(product) = command.create(save, save_movement)(valid)
  product.stock |> should.equal(0)
}
