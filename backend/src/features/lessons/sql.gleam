//// This module contains the code to run the sql queries defined in
//// `./src/features/lessons/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_lesson` query
/// defined in `./src/features/lessons/sql/create_lesson.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateLessonRow {
  CreateLessonRow(
    id: Uuid,
    name: String,
    instructor: String,
    starts_at: Timestamp,
    ends_at: Timestamp,
    capacity: Int,
    description: String,
  )
}

/// Runs the `create_lesson` query
/// defined in `./src/features/lessons/sql/create_lesson.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_lesson(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: String,
  arg_3: String,
  arg_4: Timestamp,
  arg_5: Timestamp,
  arg_6: Int,
  arg_7: String,
) -> Result(pog.Returned(CreateLessonRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use name <- decode.field(1, decode.string)
    use instructor <- decode.field(2, decode.string)
    use starts_at <- decode.field(3, pog.timestamp_decoder())
    use ends_at <- decode.field(4, pog.timestamp_decoder())
    use capacity <- decode.field(5, decode.int)
    use description <- decode.field(6, decode.string)
    decode.success(CreateLessonRow(
      id:,
      name:,
      instructor:,
      starts_at:,
      ends_at:,
      capacity:,
      description:,
    ))
  }

  "INSERT INTO app.lessons
  (id, name, instructor, starts_at, ends_at, capacity, description)
VALUES
  ($1, $2, $3, $4, $5, $6, $7)
RETURNING
  id, name, instructor, starts_at, ends_at, capacity, description
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.timestamp(arg_4))
  |> pog.parameter(pog.timestamp(arg_5))
  |> pog.parameter(pog.int(arg_6))
  |> pog.parameter(pog.text(arg_7))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `list_lesson` query
/// defined in `./src/features/lessons/sql/list_lesson.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListLessonRow {
  ListLessonRow(
    id: Uuid,
    name: String,
    instructor: String,
    starts_at: Timestamp,
    ends_at: Timestamp,
    capacity: Int,
    reserved_count: Int,
    description: String,
  )
}

/// Runs the `list_lesson` query
/// defined in `./src/features/lessons/sql/list_lesson.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_lesson(
  db: pog.Connection,
  arg_1: Timestamp,
) -> Result(pog.Returned(ListLessonRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use name <- decode.field(1, decode.string)
    use instructor <- decode.field(2, decode.string)
    use starts_at <- decode.field(3, pog.timestamp_decoder())
    use ends_at <- decode.field(4, pog.timestamp_decoder())
    use capacity <- decode.field(5, decode.int)
    use reserved_count <- decode.field(6, decode.int)
    use description <- decode.field(7, decode.string)
    decode.success(ListLessonRow(
      id:,
      name:,
      instructor:,
      starts_at:,
      ends_at:,
      capacity:,
      reserved_count:,
      description:,
    ))
  }

  "SELECT
  l.id,
  l.name,
  l.instructor,
  l.starts_at,
  l.ends_at,
  l.capacity,
  COUNT(r.id)::int AS reserved_count,
  l.description
FROM app.lessons l
LEFT JOIN app.reservations r ON r.lesson_id = l.id
WHERE l.starts_at > $1
GROUP BY l.id
ORDER BY l.starts_at ASC
"
  |> pog.query
  |> pog.parameter(pog.timestamp(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `read_lesson` query
/// defined in `./src/features/lessons/sql/read_lesson.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ReadLessonRow {
  ReadLessonRow(
    id: Uuid,
    name: String,
    instructor: String,
    starts_at: Timestamp,
    ends_at: Timestamp,
    capacity: Int,
    reserved_count: Int,
    description: String,
  )
}

/// Runs the `read_lesson` query
/// defined in `./src/features/lessons/sql/read_lesson.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn read_lesson(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(ReadLessonRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use name <- decode.field(1, decode.string)
    use instructor <- decode.field(2, decode.string)
    use starts_at <- decode.field(3, pog.timestamp_decoder())
    use ends_at <- decode.field(4, pog.timestamp_decoder())
    use capacity <- decode.field(5, decode.int)
    use reserved_count <- decode.field(6, decode.int)
    use description <- decode.field(7, decode.string)
    decode.success(ReadLessonRow(
      id:,
      name:,
      instructor:,
      starts_at:,
      ends_at:,
      capacity:,
      reserved_count:,
      description:,
    ))
  }

  "SELECT
  l.id,
  l.name,
  l.instructor,
  l.starts_at,
  l.ends_at,
  l.capacity,
  COUNT(r.id)::int AS reserved_count,
  l.description
FROM app.lessons l
LEFT JOIN app.reservations r ON r.lesson_id = l.id
WHERE l.id = $1
GROUP BY l.id
"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `read_lesson_capacity` query
/// defined in `./src/features/lessons/sql/read_lesson_capacity.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ReadLessonCapacityRow {
  ReadLessonCapacityRow(capacity: Int, reserved_count: Int)
}

/// Runs the `read_lesson_capacity` query
/// defined in `./src/features/lessons/sql/read_lesson_capacity.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn read_lesson_capacity(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(ReadLessonCapacityRow), pog.QueryError) {
  let decoder = {
    use capacity <- decode.field(0, decode.int)
    use reserved_count <- decode.field(1, decode.int)
    decode.success(ReadLessonCapacityRow(capacity:, reserved_count:))
  }

  "SELECT
  l.capacity,
  COUNT(r.id)::int AS reserved_count
FROM app.lessons l
LEFT JOIN app.reservations r ON r.lesson_id = l.id
WHERE l.id = $1
GROUP BY l.capacity;
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
