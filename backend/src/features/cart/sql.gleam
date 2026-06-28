//// This module contains the code to run the sql queries defined in
//// `./src/features/cart/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// Runs the `delete_cart_item` query
/// defined in `./src/features/cart/sql/delete_cart_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_cart_item(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM app.cart_items
WHERE id = $1
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_cart_item_by_id` query
/// defined in `./src/features/cart/sql/find_cart_item_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindCartItemByIdRow {
  FindCartItemByIdRow(
    id: Uuid,
    member_id: Uuid,
    product_id: Uuid,
    quantity: Int,
  )
}

/// Runs the `find_cart_item_by_id` query
/// defined in `./src/features/cart/sql/find_cart_item_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_cart_item_by_id(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(FindCartItemByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use member_id <- decode.field(1, uuid_decoder())
    use product_id <- decode.field(2, uuid_decoder())
    use quantity <- decode.field(3, decode.int)
    decode.success(FindCartItemByIdRow(id:, member_id:, product_id:, quantity:))
  }

  "SELECT id, member_id, product_id, quantity
FROM app.cart_items
WHERE id = $1
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_cart_item_by_member_product` query
/// defined in `./src/features/cart/sql/find_cart_item_by_member_product.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindCartItemByMemberProductRow {
  FindCartItemByMemberProductRow(
    id: Uuid,
    member_id: Uuid,
    product_id: Uuid,
    quantity: Int,
  )
}

/// Runs the `find_cart_item_by_member_product` query
/// defined in `./src/features/cart/sql/find_cart_item_by_member_product.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_cart_item_by_member_product(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Uuid,
) -> Result(pog.Returned(FindCartItemByMemberProductRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use member_id <- decode.field(1, uuid_decoder())
    use product_id <- decode.field(2, uuid_decoder())
    use quantity <- decode.field(3, decode.int)
    decode.success(FindCartItemByMemberProductRow(
      id:,
      member_id:,
      product_id:,
      quantity:,
    ))
  }

  "SELECT id, member_id, product_id, quantity
FROM app.cart_items
WHERE member_id = $1
  AND product_id = $2
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_cart_items_by_member` query
/// defined in `./src/features/cart/sql/find_cart_items_by_member.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindCartItemsByMemberRow {
  FindCartItemsByMemberRow(
    id: Uuid,
    product_id: Uuid,
    name: String,
    price: Int,
    quantity: Int,
  )
}

/// Runs the `find_cart_items_by_member` query
/// defined in `./src/features/cart/sql/find_cart_items_by_member.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_cart_items_by_member(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(FindCartItemsByMemberRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use product_id <- decode.field(1, uuid_decoder())
    use name <- decode.field(2, decode.string)
    use price <- decode.field(3, decode.int)
    use quantity <- decode.field(4, decode.int)
    decode.success(FindCartItemsByMemberRow(
      id:,
      product_id:,
      name:,
      price:,
      quantity:,
    ))
  }

  "SELECT ci.id, ci.product_id, p.name, p.price, ci.quantity
FROM app.cart_items ci
JOIN app.products p ON ci.product_id = p.id
WHERE ci.member_id = $1
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `save_cart_item` query
/// defined in `./src/features/cart/sql/save_cart_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type SaveCartItemRow {
  SaveCartItemRow(id: Uuid, member_id: Uuid, product_id: Uuid, quantity: Int)
}

/// Runs the `save_cart_item` query
/// defined in `./src/features/cart/sql/save_cart_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn save_cart_item(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Uuid,
  arg_3: Uuid,
  arg_4: Int,
) -> Result(pog.Returned(SaveCartItemRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use member_id <- decode.field(1, uuid_decoder())
    use product_id <- decode.field(2, uuid_decoder())
    use quantity <- decode.field(3, decode.int)
    decode.success(SaveCartItemRow(id:, member_id:, product_id:, quantity:))
  }

  "INSERT INTO app.cart_items (id, member_id, product_id, quantity)
VALUES ($1, $2, $3, $4)
RETURNING id, member_id, product_id, quantity
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(uuid.to_string(arg_3)))
  |> pog.parameter(pog.int(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `update_cart_item_quantity` query
/// defined in `./src/features/cart/sql/update_cart_item_quantity.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpdateCartItemQuantityRow {
  UpdateCartItemQuantityRow(
    id: Uuid,
    member_id: Uuid,
    product_id: Uuid,
    quantity: Int,
  )
}

/// Runs the `update_cart_item_quantity` query
/// defined in `./src/features/cart/sql/update_cart_item_quantity.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_cart_item_quantity(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Int,
) -> Result(pog.Returned(UpdateCartItemQuantityRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use member_id <- decode.field(1, uuid_decoder())
    use product_id <- decode.field(2, uuid_decoder())
    use quantity <- decode.field(3, decode.int)
    decode.success(UpdateCartItemQuantityRow(
      id:,
      member_id:,
      product_id:,
      quantity:,
    ))
  }

  "UPDATE app.cart_items
SET quantity = $2
WHERE id = $1
RETURNING id, member_id, product_id, quantity
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.int(arg_2))
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
