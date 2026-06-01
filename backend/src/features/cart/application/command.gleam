import generated/requests.{type AddCartItemInput, type UpdateCartItemInput}
import generated/responses.{type CartItem, CartItem}
import gleam/option.{type Option}
import gleam/result
import youid/uuid.{type Uuid}

pub opaque type ValidAddCartItemInput {
  ValidAddCartItemInput(product_id: Uuid, quantity: Int)
}

pub opaque type ValidUpdateCartItemInput {
  ValidUpdateCartItemInput(quantity: Int)
}

pub type FindStock =
  fn(Uuid) -> Result(Int, String)

pub type FindCartItem =
  fn(Uuid, Uuid) -> Result(Option(CartItem), String)

pub type SaveCartItem =
  fn(CartItem) -> Result(CartItem, String)

pub type UpdateCartItem =
  fn(Uuid, Int) -> Result(CartItem, String)

pub type Create =
  fn(Uuid, ValidAddCartItemInput) -> Result(CartItem, String)

pub type Update =
  fn(Uuid, ValidUpdateCartItemInput) -> Result(CartItem, String)

pub fn validate(input: AddCartItemInput) -> Result(ValidAddCartItemInput, List(String)) {
  let errors = []
  case errors {
    [] -> Ok(ValidAddCartItemInput(product_id: input.product_id, quantity: input.quantity))
    _ -> Error(errors)
  }
}

pub fn validate_update(input: UpdateCartItemInput) -> Result(ValidUpdateCartItemInput, List(String)) {
  let errors = []
  case errors {
    [] -> Ok(ValidUpdateCartItemInput(quantity: input.quantity))
    _ -> Error(errors)
  }
}

pub fn create(
  save: SaveCartItem,
  find_stock: FindStock,
  find_cart_item: FindCartItem,
) -> Create {
  fn(member_id: Uuid, input: ValidAddCartItemInput) {
    let ValidAddCartItemInput(product_id, quantity) = input
    use stock <- result.try(find_stock(product_id))
    use existing <- result.try(find_cart_item(member_id, product_id))
    case stock, existing {
      0, _ -> Error("out of stock")
      _, option.Some(_) -> Error("already in cart")
      _, option.None -> {
        let item =
          CartItem(
            id: uuid.v4(),
            product_id:,
            name: "",
            price: 0,
            quantity:,
          )
        save(item)
      }
    }
  }
}

pub fn update(update_item: UpdateCartItem) -> Update {
  fn(id: Uuid, input: ValidUpdateCartItemInput) {
    let ValidUpdateCartItemInput(quantity) = input
    update_item(id, quantity)
  }
}

