// This file is auto-generated from openapi.yaml. Do not edit manually.
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/int
import gleam/string
import gleam/time/timestamp
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

pub type CreateReservationInput {
  CreateReservationInput(
    lesson_id: Uuid,
  )
}

fn decode_create_reservation_input(value: Dynamic) -> Result(CreateReservationInput, List(decode.DecodeError)) {
  decode.run(value, {
    use lesson_id <- decode.field("lesson_id", decode_uuid_field())
    decode.success(CreateReservationInput(
      lesson_id:,
    ))
  })
}

pub type CreateLessonInput {
  CreateLessonInput(
    name: String,
    instructor: String,
    starts_at: String,
    ends_at: String,
    capacity: Int,
    description: String,
  )
}

fn decode_create_lesson_input(value: Dynamic) -> Result(CreateLessonInput, List(decode.DecodeError)) {
  decode.run(value, {
    use name <- decode.field("name", decode.string)
    use instructor <- decode.field("instructor", decode.string)
    use starts_at <- decode.field("startsAt", decode.string)
    use ends_at <- decode.field("endsAt", decode.string)
    use capacity <- decode.field("capacity", decode.int)
    use description <- decode.field("description", decode.string)
    decode.success(CreateLessonInput(
      name:,
      instructor:,
      starts_at:,
      ends_at:,
      capacity:,
      description:,
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

fn validate_create_reservation_input(input: CreateReservationInput) -> Result(CreateReservationInput, List(String)) {
  let errors =
    []
  case errors {
    [] -> Ok(input)
    _ -> Error(errors)
  }
}

pub fn parse_create_reservation_input(value: Dynamic) -> Result(CreateReservationInput, List(String)) {
  case decode_create_reservation_input(value) {
    Error(_) -> Error(["invalid request body"])
    Ok(input) -> validate_create_reservation_input(input)
  }
}

fn validate_create_lesson_input(input: CreateLessonInput) -> Result(CreateLessonInput, List(String)) {
  let errors =
    []
    |> check_min_length("name", input.name, 1)
    |> check_min_length("instructor", input.instructor, 1)
    |> check_date_time("startsAt", input.starts_at)
    |> check_date_time("endsAt", input.ends_at)
    |> check_min_int("capacity", input.capacity, 1)
  case errors {
    [] -> Ok(input)
    _ -> Error(errors)
  }
}

pub fn parse_create_lesson_input(value: Dynamic) -> Result(CreateLessonInput, List(String)) {
  case decode_create_lesson_input(value) {
    Error(_) -> Error(["invalid request body"])
    Ok(input) -> validate_create_lesson_input(input)
  }
}

fn check_min_length(errors: List(String), field: String, value: String, min: Int) -> List(String) {
  case string.length(value) >= min {
    True -> errors
    False -> [field <> " must be at least " <> int.to_string(min) <> " characters", ..errors]
  }
}

fn check_date_time(errors: List(String), field: String, value: String) -> List(String) {
  case timestamp.parse_rfc3339(value) {
    Ok(_) -> errors
    Error(_) -> [field <> " is not a valid date-time", ..errors]
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
