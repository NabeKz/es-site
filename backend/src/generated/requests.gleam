// This file is auto-generated from openapi.yaml. Do not edit manually.
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/int
import gleam/string
import youid/uuid.{type Uuid}

pub type AuthInput {
  AuthInput(
    email: String,
    password: String,
  )
}

fn decode_auth_input(value: Dynamic) -> Result(AuthInput, List(decode.DecodeError)) {
  decode.run(value, {
    use email <- decode.field("email", decode.string)
    use password <- decode.field("password", decode.string)
    decode.success(AuthInput(
      email:,
      password:,
    ))
  })
}

pub type CreateProductInput {
  CreateProductInput(
    name: String,
    price: Int,
    stock: Int,
    description: String,
  )
}

fn decode_create_product_input(value: Dynamic) -> Result(CreateProductInput, List(decode.DecodeError)) {
  decode.run(value, {
    use name <- decode.field("name", decode.string)
    use price <- decode.field("price", decode.int)
    use stock <- decode.field("stock", decode.int)
    use description <- decode.field("description", decode.string)
    decode.success(CreateProductInput(
      name:,
      price:,
      stock:,
      description:,
    ))
  })
}

pub type AddCartItemInput {
  AddCartItemInput(
    product_id: Uuid,
    quantity: Int,
  )
}

fn decode_add_cart_item_input(value: Dynamic) -> Result(AddCartItemInput, List(decode.DecodeError)) {
  decode.run(value, {
    use product_id <- decode.field("productId", decode_uuid_field())
    use quantity <- decode.field("quantity", decode.int)
    decode.success(AddCartItemInput(
      product_id:,
      quantity:,
    ))
  })
}

pub type UpdateCartItemInput {
  UpdateCartItemInput(
    quantity: Int,
  )
}

fn decode_update_cart_item_input(value: Dynamic) -> Result(UpdateCartItemInput, List(decode.DecodeError)) {
  decode.run(value, {
    use quantity <- decode.field("quantity", decode.int)
    decode.success(UpdateCartItemInput(
      quantity:,
    ))
  })
}

fn validate_auth_input(input: AuthInput) -> Result(AuthInput, List(String)) {
  let errors =
    []
    |> check_min_length("email", input.email, 1)
    |> check_min_length("password", input.password, 8)
  case errors {
    [] -> Ok(input)
    _ -> Error(errors)
  }
}

pub fn parse_auth_input(value: Dynamic) -> Result(AuthInput, List(String)) {
  case decode_auth_input(value) {
    Error(_) -> Error(["invalid request body"])
    Ok(input) -> validate_auth_input(input)
  }
}

fn validate_create_product_input(input: CreateProductInput) -> Result(CreateProductInput, List(String)) {
  let errors =
    []
    |> check_min_length("name", input.name, 1)
    |> check_min_int("price", input.price, 1)
    |> check_min_int("stock", input.stock, 0)
  case errors {
    [] -> Ok(input)
    _ -> Error(errors)
  }
}

pub fn parse_create_product_input(value: Dynamic) -> Result(CreateProductInput, List(String)) {
  case decode_create_product_input(value) {
    Error(_) -> Error(["invalid request body"])
    Ok(input) -> validate_create_product_input(input)
  }
}

fn validate_add_cart_item_input(input: AddCartItemInput) -> Result(AddCartItemInput, List(String)) {
  let errors =
    []
    |> check_min_int("quantity", input.quantity, 1)
  case errors {
    [] -> Ok(input)
    _ -> Error(errors)
  }
}

pub fn parse_add_cart_item_input(value: Dynamic) -> Result(AddCartItemInput, List(String)) {
  case decode_add_cart_item_input(value) {
    Error(_) -> Error(["invalid request body"])
    Ok(input) -> validate_add_cart_item_input(input)
  }
}

fn validate_update_cart_item_input(input: UpdateCartItemInput) -> Result(UpdateCartItemInput, List(String)) {
  let errors =
    []
    |> check_min_int("quantity", input.quantity, 1)
  case errors {
    [] -> Ok(input)
    _ -> Error(errors)
  }
}

pub fn parse_update_cart_item_input(value: Dynamic) -> Result(UpdateCartItemInput, List(String)) {
  case decode_update_cart_item_input(value) {
    Error(_) -> Error(["invalid request body"])
    Ok(input) -> validate_update_cart_item_input(input)
  }
}

fn check_min_length(errors: List(String), field: String, value: String, min: Int) -> List(String) {
  case string.length(value) >= min {
    True -> errors
    False -> [field <> " must be at least " <> int.to_string(min) <> " characters", ..errors]
  }
}

fn check_min_int(errors: List(String), field: String, value: Int, min: Int) -> List(String) {
  case value >= min {
    True -> errors
    False -> [field <> " must be at least " <> int.to_string(min), ..errors]
  }
}

fn decode_uuid_field() -> decode.Decoder(uuid.Uuid) {
  use s <- decode.then(decode.string)
  case uuid.from_string(s) {
    Ok(u) -> decode.success(u)
    Error(_) -> decode.failure(uuid.nil, "UUID")
  }
}
