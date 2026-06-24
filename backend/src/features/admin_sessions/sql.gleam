//// This module contains the code to run the sql queries defined in
//// `./src/features/admin_sessions/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_admin_session` query
/// defined in `./src/features/admin_sessions/sql/create_admin_session.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateAdminSessionRow {
  CreateAdminSessionRow(id: Uuid, admin_id: Uuid, token: String)
}

/// Runs the `create_admin_session` query
/// defined in `./src/features/admin_sessions/sql/create_admin_session.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_admin_session(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Uuid,
  arg_3: String,
  arg_4: Timestamp,
) -> Result(pog.Returned(CreateAdminSessionRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use admin_id <- decode.field(1, uuid_decoder())
    use token <- decode.field(2, decode.string)
    decode.success(CreateAdminSessionRow(id:, admin_id:, token:))
  }

  "INSERT INTO app.admin_sessions (id, admin_id, token, created_at)
VALUES ($1, $2, $3, $4)
RETURNING id, admin_id, token
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.timestamp(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_admin_session` query
/// defined in `./src/features/admin_sessions/sql/delete_admin_session.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_admin_session(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM app.admin_sessions
WHERE token = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_admin_session_by_token` query
/// defined in `./src/features/admin_sessions/sql/find_admin_session_by_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindAdminSessionByTokenRow {
  FindAdminSessionByTokenRow(id: Uuid, admin_id: Uuid, token: String)
}

/// Runs the `find_admin_session_by_token` query
/// defined in `./src/features/admin_sessions/sql/find_admin_session_by_token.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_admin_session_by_token(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(FindAdminSessionByTokenRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use admin_id <- decode.field(1, uuid_decoder())
    use token <- decode.field(2, decode.string)
    decode.success(FindAdminSessionByTokenRow(id:, admin_id:, token:))
  }

  "SELECT id, admin_id, token
FROM app.admin_sessions
WHERE token = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
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
