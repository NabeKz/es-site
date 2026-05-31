import wisp.{type Response}
import youid/uuid

pub fn require_uuid(id: String, next: fn(uuid.Uuid) -> Response) -> Response {
  case uuid.from_string(id) {
    Ok(u) -> next(u)
    Error(_) -> wisp.bad_request("Invalid ID")
  }
}
