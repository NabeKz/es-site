import generated/requests
import generated/responses
import gleam/json
import wisp.{type Request, type Response}

import app/handlers/request
import app/handlers/response
import app/handlers/validation
import features/lessons/application
import shared/date

pub type LessonHandler {
  LessonHandler(
    create: fn(Request) -> Response,
    read: fn(String) -> Response,
    list: fn(Request) -> Response,
  )
}

fn create(create_lesson: application.CreateLesson, req: Request) -> Response {
  use input <- request.require_json_body(req, requests.parse_create_lesson_input)

  case create_lesson(input) {
    Ok(lesson) ->
      lesson
      |> responses.encode_lesson
      |> response.json_response(201)
    Error(err) -> wisp.bad_request(err)
  }
}

fn read(read_lesson: application.ReadLesson, id: String) -> Response {
  use lesson_uuid <- validation.require_uuid(id)
  case read_lesson(lesson_uuid) {
    Ok(lesson) ->
      lesson
      |> responses.encode_lesson
      |> response.json_response(200)
    Error(_) -> wisp.not_found()
  }
}

fn list(list_lesson: application.ListLesson, _req: Request) -> Response {
  case list_lesson(date.now()) {
    Ok(rows) ->
      rows
      |> json.array(responses.encode_lesson)
      |> response.json_response(200)
    Error(err) -> wisp.bad_request(err)
  }
}

pub fn new(
  create_lesson: application.CreateLesson,
  read_lesson: application.ReadLesson,
  list_lesson: application.ListLesson,
) -> LessonHandler {
  LessonHandler(
    create: create(create_lesson, _),
    read: read(read_lesson, _),
    list: list(list_lesson, _),
  )
}
