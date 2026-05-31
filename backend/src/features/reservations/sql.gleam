//// This module contains the code to run the sql queries defined in
//// `./src/features/reservations/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_reservation` query
/// defined in `./src/features/reservations/sql/create_reservation.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateReservationRow {
  CreateReservationRow(id: Uuid)
}

/// Runs the `create_reservation` query
/// defined in `./src/features/reservations/sql/create_reservation.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_reservation(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Uuid,
  arg_3: Uuid,
) -> Result(pog.Returned(CreateReservationRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    decode.success(CreateReservationRow(id:))
  }

  "INSERT INTO app.reservations (id, lesson_id, member_id)
VALUES ($1, $2, $3)
RETURNING id;
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.parameter(pog.text(uuid.to_string(arg_3)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_reservation` query
/// defined in `./src/features/reservations/sql/delete_reservation.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_reservation(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM app.reservations
WHERE id = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `list_my_reservations` query
/// defined in `./src/features/reservations/sql/list_my_reservations.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListMyReservationsRow {
  ListMyReservationsRow(id: Uuid, lesson_id: Uuid)
}

/// Runs the `list_my_reservations` query
/// defined in `./src/features/reservations/sql/list_my_reservations.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_my_reservations(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(ListMyReservationsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use lesson_id <- decode.field(1, uuid_decoder())
    decode.success(ListMyReservationsRow(id:, lesson_id:))
  }

  "SELECT
    r.id,
    r.lesson_id
FROM
    app.reservations r
WHERE
    r.member_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `read_member_reservation` query
/// defined in `./src/features/reservations/sql/read_member_reservation.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ReadMemberReservationRow {
  ReadMemberReservationRow(id: Uuid)
}

/// Runs the `read_member_reservation` query
/// defined in `./src/features/reservations/sql/read_member_reservation.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn read_member_reservation(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Uuid,
) -> Result(pog.Returned(ReadMemberReservationRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    decode.success(ReadMemberReservationRow(id:))
  }

  "SELECT id
FROM app.reservations
WHERE lesson_id = $1
  AND member_id = $2
LIMIT 1;
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(uuid.to_string(arg_2)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `read_reservation_info` query
/// defined in `./src/features/reservations/sql/read_reservation_info.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ReadReservationInfoRow {
  ReadReservationInfoRow(id: Uuid, lesson_id: Uuid, member_id: Uuid)
}

/// Runs the `read_reservation_info` query
/// defined in `./src/features/reservations/sql/read_reservation_info.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn read_reservation_info(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(ReadReservationInfoRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use lesson_id <- decode.field(1, uuid_decoder())
    use member_id <- decode.field(2, uuid_decoder())
    decode.success(ReadReservationInfoRow(id:, lesson_id:, member_id:))
  }

  "SELECT
    id,
    lesson_id,
    member_id
FROM
    app.reservations
WHERE
    id = $1;
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
