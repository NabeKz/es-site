import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/otp/actor
import gleam/result
import youid/uuid.{type Uuid}

import workflows/lesson_reservation_actor

pub opaque type RegistryMessage {
  Register(
    lesson_id: Uuid,
    subject: process.Subject(lesson_reservation_actor.Message),
  )
  Deregister(lesson_id: Uuid)
  Lookup(
    lesson_id: Uuid,
    reply_to: process.Subject(
      Result(process.Subject(lesson_reservation_actor.Message), String),
    ),
  )
}

type State =
  Dict(Uuid, process.Subject(lesson_reservation_actor.Message))

pub fn start() -> actor.StartResult(process.Subject(RegistryMessage)) {
  actor.new(dict.new())
  |> actor.on_message(handle_message)
  |> actor.start()
}

pub fn register(
  registry: process.Subject(RegistryMessage),
  lesson_id: Uuid,
  subject: process.Subject(lesson_reservation_actor.Message),
) -> Nil {
  process.send(registry, Register(lesson_id:, subject:))
}

pub fn deregister(
  registry: process.Subject(RegistryMessage),
  lesson_id: Uuid,
) -> Nil {
  process.send(registry, Deregister(lesson_id:))
}

pub fn lookup(
  registry: process.Subject(RegistryMessage),
  lesson_id: Uuid,
) -> Result(process.Subject(lesson_reservation_actor.Message), String) {
  let reply = process.new_subject()
  process.send(registry, Lookup(lesson_id:, reply_to: reply))
  process.receive(reply, 1000)
  |> result.map_error(fn(_) { "not available" })
  |> result.flatten()
}

fn handle_message(
  state: State,
  msg: RegistryMessage,
) -> actor.Next(State, RegistryMessage) {
  case msg {
    Register(lesson_id:, subject:) ->
      actor.continue(dict.insert(state, lesson_id, subject))
    Deregister(lesson_id:) ->
      actor.continue(dict.delete(state, lesson_id))
    Lookup(lesson_id:, reply_to:) -> {
      let result = case dict.get(state, lesson_id) {
        Ok(subject) -> Ok(subject)
        Error(Nil) -> Error("not available")
      }
      process.send(reply_to, result)
      actor.continue(state)
    }
  }
}
