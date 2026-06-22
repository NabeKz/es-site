import gleam/int
import gleam/result
import generated/requests.{type CreateProductInput}
import generated/responses.{type Product, Product}
import youid/uuid

pub opaque type ValidProductInput {
  ValidProductInput(name: String, price: Int, stock: Int, description: String)
}

pub type SaveProduct =
  fn(Product) -> Result(Product, String)

pub type SaveStockMovement =
  fn(uuid.Uuid, Int, String) -> Result(Nil, String)

pub type Create =
  fn(ValidProductInput) -> Result(Product, String)

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

pub fn create(save: SaveProduct, save_movement: SaveStockMovement) -> Create {
  fn(input: ValidProductInput) {
    do_create(save, save_movement, input)
  }
}

fn do_create(
  save: SaveProduct,
  save_movement: SaveStockMovement,
  input: ValidProductInput,
) -> Result(Product, String) {
  let ValidProductInput(name, price, stock, description) = input
  let product = Product(id: uuid.v4(), name:, price:, stock:, description:)
  use product <- result.try(save(product))
  case stock > 0 {
    True -> {
      use _ <- result.try(save_movement(product.id, stock, "initial"))
      Ok(product)
    }
    False -> Ok(product)
  }
}
