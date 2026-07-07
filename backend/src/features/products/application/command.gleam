import gleam/int
import gleam/result
import generated/requests.{type CreateProductInput}
import generated/responses.{type OrderItem, type Product, Product}
import youid/uuid.{type Uuid}

pub opaque type ValidProductInput {
  ValidProductInput(name: String, price: Int, stock: Int, description: String)
}

pub type GenerateId =
  fn() -> Uuid

pub type SaveProduct =
  fn(Product) -> Result(Product, String)

pub type SaveStockMovement =
  fn(Uuid, Int, String) -> Result(Nil, String)

pub type Create =
  fn(Uuid, ValidProductInput) -> Result(Product, String)

/// 複数商品の在庫を引き当てる（実機は `product_id` 単位のアドバイザリロックで直列化）。
pub type Allocate =
  fn(List(OrderItem)) -> Result(Nil, String)

/// 引き当てた在庫を戻す（決済失敗時の補償。UC-6 補償）。
pub type ReturnStock =
  fn(List(OrderItem)) -> Result(Nil, String)

pub fn validate(input: CreateProductInput) -> Result(ValidProductInput, List(String)) {
  let errors =
    []
    |> check_price_limit(input.price, 100_000)
  case errors {
    [] ->
      Ok(ValidProductInput(
        name: input.name,
        price: input.price,
        stock: input.stock,
        description: input.description,
      ))
    _ -> Error(errors)
  }
}

fn check_price_limit(errors: List(String), price: Int, max: Int) -> List(String) {
  case price <= max {
    True -> errors
    False -> ["price must be at most " <> int.to_string(max), ..errors]
  }
}

pub fn create(
  generate_id: GenerateId,
  save: SaveProduct,
  save_movement: SaveStockMovement,
) -> Create {
  fn(_admin_id: Uuid, input: ValidProductInput) {
    do_create(generate_id, save, save_movement, input)
  }
}

fn do_create(
  generate_id: GenerateId,
  save: SaveProduct,
  save_movement: SaveStockMovement,
  input: ValidProductInput,
) -> Result(Product, String) {
  let ValidProductInput(name, price, stock, description) = input
  let product = Product(id: generate_id(), name:, price:, stock:, description:)
  use product <- result.try(save(product))
  case stock > 0 {
    True -> {
      use _ <- result.try(save_movement(product.id, stock, "initial"))
      Ok(product)
    }
    False -> Ok(product)
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
