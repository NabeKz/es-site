import gleam/dynamic

import wisp.{type Request, type Response}

import app/handlers/error_responses

pub fn require_json_body(
  req: Request,
  parser: fn(dynamic.Dynamic) -> Result(a, List(String)),
  next: fn(a) -> Response,
) -> Response {
  use body <- wisp.require_json(req)
  use input <- error_responses.require_ok(body |> parser)
  next(input)
}
