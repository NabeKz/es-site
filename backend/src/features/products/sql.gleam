//// This module contains the code to run the sql queries defined in
//// `./src/features/products/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_product` query
/// defined in `./src/features/products/sql/create_product.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateProductRow {
  CreateProductRow(id: Uuid, name: String, price: Int, description: String)
}

/// Runs the `create_product` query
/// defined in `./src/features/products/sql/create_product.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_product(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: String,
  arg_3: Int,
  arg_4: String,
) -> Result(pog.Returned(CreateProductRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use name <- decode.field(1, decode.string)
    use price <- decode.field(2, decode.int)
    use description <- decode.field(3, decode.string)
    decode.success(CreateProductRow(id:, name:, price:, description:))
  }

  "INSERT INTO app.products (id, name, price, description)
VALUES ($1, $2, $3, $4)
RETURNING id, name, price, description
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_stock_by_product` query
/// defined in `./src/features/products/sql/find_stock_by_product.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindStockByProductRow {
  FindStockByProductRow(stock: Int)
}

/// Runs the `find_stock_by_product` query
/// defined in `./src/features/products/sql/find_stock_by_product.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_stock_by_product(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(FindStockByProductRow), pog.QueryError) {
  let decoder = {
    use stock <- decode.field(0, decode.int)
    decode.success(FindStockByProductRow(stock:))
  }

  "SELECT COALESCE(SUM(delta), 0)::int AS stock
FROM app.stock_movements
WHERE product_id = $1
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
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
