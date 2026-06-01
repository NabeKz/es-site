import generated/requests.{type CreateProductInput}
import generated/responses.{type Product, Product}
import youid/uuid

pub opaque type ValidProductInput {
  ValidProductInput(name: String, price: Int, stock: Int, description: String)
}

pub type SaveProduct =
  fn(Product) -> Result(Product, String)

pub type Create =
  fn(ValidProductInput) -> Result(Product, String)

pub fn validate(input: CreateProductInput) -> Result(ValidProductInput, List(String)) {
  let errors = []
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

pub fn create(save: SaveProduct) -> Create {
  fn(input: ValidProductInput) {
    let ValidProductInput(name, price, stock, description) = input
    let product =
      Product(id: uuid.v4(), name:, price:, stock:, description:)
    save(product)
  }
}
