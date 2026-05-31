//// This module contains the code to run the sql queries defined in
//// `./src/features/members/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_member` query
/// defined in `./src/features/members/sql/create_member.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateMemberRow {
  CreateMemberRow(id: Uuid, email: String, password_hash: String, salt: String)
}

/// Runs the `create_member` query
/// defined in `./src/features/members/sql/create_member.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_member(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: String,
  arg_3: String,
  arg_4: String,
) -> Result(pog.Returned(CreateMemberRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use email <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use salt <- decode.field(3, decode.string)
    decode.success(CreateMemberRow(id:, email:, password_hash:, salt:))
  }

  "INSERT INTO app.members (id, email, password_hash, salt)
VALUES ($1, $2, $3, $4)
RETURNING id, email, password_hash, salt
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_member_by_email` query
/// defined in `./src/features/members/sql/find_member_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindMemberByEmailRow {
  FindMemberByEmailRow(
    id: Uuid,
    email: String,
    password_hash: String,
    salt: String,
  )
}

/// Runs the `find_member_by_email` query
/// defined in `./src/features/members/sql/find_member_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_member_by_email(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(FindMemberByEmailRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use email <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use salt <- decode.field(3, decode.string)
    decode.success(FindMemberByEmailRow(id:, email:, password_hash:, salt:))
  }

  "SELECT id, email, password_hash, salt
FROM app.members
WHERE email = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_member_by_id` query
/// defined in `./src/features/members/sql/find_member_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindMemberByIdRow {
  FindMemberByIdRow(
    id: Uuid,
    email: String,
    password_hash: String,
    salt: String,
  )
}

/// Runs the `find_member_by_id` query
/// defined in `./src/features/members/sql/find_member_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_member_by_id(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(FindMemberByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use email <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use salt <- decode.field(3, decode.string)
    decode.success(FindMemberByIdRow(id:, email:, password_hash:, salt:))
  }

  "SELECT id, email, password_hash, salt
FROM app.members
WHERE id = $1
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
