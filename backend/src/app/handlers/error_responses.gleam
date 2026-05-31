import gleam/http/response
import gleam/json

import wisp.{type Response}

pub fn require_ok(
  result: Result(a, List(String)),
  next: fn(a) -> Response,
) -> Response {
  case result {
    Error(errors) -> unprocessable_entity(errors)
    Ok(value) -> next(value)
  }
}

fn unprocessable_entity(errors: List(String)) -> Response {
  let body =
    json.object([
      #("type", json.string("about:blank")),
      #("title", json.string("Unprocessable Content")),
      #("status", json.int(422)),
      #("errors", json.array(errors, json.string)),
    ])

  body
  |> json.to_string
  |> wisp.json_response(422)
  |> response.set_header("content-type", "application/problem+json")
}
