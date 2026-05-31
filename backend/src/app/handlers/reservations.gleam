import gleam/http/response
import gleam/json
import wisp.{type Request, type Response}
import youid/uuid

import app/handlers/auth
import app/handlers/request as req_helper
import features/reservations/application/command
import features/reservations/application as reservations_app
import workflows/create_reservation
import features/sessions/application as sessions_app
import generated/requests
import generated/responses
import shared/date

pub type ReservationHandler {
  ReservationHandler(
    create: fn(Request) -> Response,
    cancel: fn(Request, String) -> Response,
    list_my: fn(Request) -> Response,
  )
}

fn create(
  find_session: sessions_app.FindMemberIdByToken,
  create_fn: create_reservation.CreateReservation,
  req: Request,
) -> Response {
  use member_id <- require_member_id(find_session, req)
  use input <- req_helper.require_json_body(req, requests.parse_create_reservation_input)
  case create_fn(member_id, input) {
    Ok(reservation) ->
      reservation
      |> responses.encode_reservation
      |> json.to_string
      |> wisp.json_response(201)
    Error("not found") -> wisp.not_found()
    Error("already reserved") -> wisp.response(409)
    Error("full") -> wisp.response(409)
    Error(err) -> wisp.bad_request(err)
  }
}

fn list_my(
  find_session: sessions_app.FindMemberIdByToken,
  list_my_fn: reservations_app.ListMyReservations,
  req: Request,
) -> Response {
  use member_id <- require_member_id(find_session, req)
  case list_my_fn(member_id) {
    Ok(reservations) ->
      json.array(reservations, responses.encode_reservation)
      |> json.to_string
      |> wisp.json_response(200)
    Error(err) -> wisp.bad_request(err)
  }
}

fn cancel(
  find_session: sessions_app.FindMemberIdByToken,
  cancel_fn: command.Cancel,
  req: Request,
  id: String,
) -> Response {
  use member_id <- require_member_id(find_session, req)
  use reservation_id <- require_uuid(id)
  case cancel_fn(command.CancelInput(reservation_id:, member_id:, now: date.now())) {
    Ok(_) -> wisp.response(204)
    Error("not found") -> wisp.not_found()
    Error("not your reservation") -> wisp.response(403)
    Error("lesson has already started") -> wisp.response(409)
    Error(err) -> wisp.bad_request(err)
  }
}

fn require_member_id(
  find_session: sessions_app.FindMemberIdByToken,
  req: Request,
  next: fn(uuid.Uuid) -> Response,
) -> Response {
  case wisp.get_cookie(req, auth.session_cookie, wisp.Signed) {
    Error(_) -> unauthorized()
    Ok(token) ->
      case find_session(token) {
        Error(_) -> unauthorized()
        Ok(member_id) -> next(member_id)
      }
  }
}

fn require_uuid(raw: String, next: fn(uuid.Uuid) -> Response) -> Response {
  case uuid.from_string(raw) {
    Error(_) -> wisp.not_found()
    Ok(id) -> next(id)
  }
}

fn unauthorized() -> Response {
  json.object([
    #("type", json.string("about:blank")),
    #("title", json.string("Unauthorized")),
    #("status", json.int(401)),
  ])
  |> json.to_string
  |> wisp.json_response(401)
  |> response.set_header("content-type", "application/problem+json")
}

pub fn new(
  find_session: sessions_app.FindMemberIdByToken,
  create_fn: create_reservation.CreateReservation,
  cancel_fn: command.Cancel,
  list_my_fn: reservations_app.ListMyReservations,
) -> ReservationHandler {
  ReservationHandler(
    create: create(find_session, create_fn, _),
    cancel: fn(req, id) { cancel(find_session, cancel_fn, req, id) },
    list_my: list_my(find_session, list_my_fn, _),
  )
}
