import gleam/json

import wisp.{type Response}

pub fn json_response(value: json.Json, status: Int) -> Response {
  value |> json.to_string |> wisp.json_response(status)
}
