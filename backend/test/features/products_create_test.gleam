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

// test: DB エラー時は Error を返す
pub fn create_product_adaptor_error_test() {
  let assert Ok(valid) = command.validate(fixture_input())
  let save = fn(_: Product) { Error("db error") }
  command.create(save)(valid) |> should.be_error
}

// test: 価格の上限を超えたらエラー
pub fn create_product_price_too_high_test() {
  todo
}
