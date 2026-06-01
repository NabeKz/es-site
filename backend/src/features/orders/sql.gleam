//// This module contains the code to run the sql queries defined in
//// `./src/features/orders/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_order` query
/// defined in `./src/features/orders/sql/create_order.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateOrderRow {
  CreateOrderRow(
    id: Uuid,
    member_id: Uuid,
    total_price: Int,
    created_at: Timestamp,
  )
}

/// Runs the `create_order` query
/// defined in `./src/features/orders/sql/create_order.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_order(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Uuid,
  arg_3: Int,
  arg_4: Timestamp,
) -> Result(pog.Returned(CreateOrderRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use member_id <- decode.field(1, uuid_decoder())
    use total_price <- decode.field(2, decode.int)
    use created_at <- decode.field(3, pog.timestamp_decoder())
    decode.success(CreateOrderRow(id:, member_id:, total_price:, created_at:))
  }

  "INSERT INTO app.orders (id, member_id, total_price, created_at)
VALUES ($1, $2, $3, $4)
RETURNING id, member_id, total_price, created_at
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.int(arg_3))
  |> pog.parameter(pog.timestamp(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_order_item` query
/// defined in `./src/features/orders/sql/create_order_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateOrderItemRow {
  CreateOrderItemRow(
    id: Uuid,
    order_id: Uuid,
    product_id: Uuid,
    name: String,
    unit_price: Int,
    quantity: Int,
  )
}

/// Runs the `create_order_item` query
/// defined in `./src/features/orders/sql/create_order_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_order_item(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Uuid,
  arg_3: Uuid,
  arg_4: String,
  arg_5: Int,
  arg_6: Int,
) -> Result(pog.Returned(CreateOrderItemRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use order_id <- decode.field(1, uuid_decoder())
    use product_id <- decode.field(2, uuid_decoder())
    use name <- decode.field(3, decode.string)
    use unit_price <- decode.field(4, decode.int)
    use quantity <- decode.field(5, decode.int)
    decode.success(CreateOrderItemRow(
      id:,
      order_id:,
      product_id:,
      name:,
      unit_price:,
      quantity:,
    ))
  }

  "INSERT INTO app.order_items (id, order_id, product_id, name, unit_price, quantity)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id, order_id, product_id, name, unit_price, quantity
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(uuid.to_string(arg_3)))
  |> pog.parameter(pog.text(arg_4))
  |> pog.parameter(pog.int(arg_5))
  |> pog.parameter(pog.int(arg_6))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "Uuid")
  }
}
