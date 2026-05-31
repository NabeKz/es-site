import gleam/erlang/process
import gleam/otp/actor
import gleam/result
import gleam/time/duration
import gleam/time/timestamp
import youid/uuid.{type Uuid}

import generated/requests
import generated/responses.{type Reservation}
import workflows/create_reservation

pub type ActorState {
  ActorState(
    lesson_id: Uuid,
    on_shutdown: fn(Uuid) -> Nil,
    reserve: create_reservation.CreateReservation,
  )
}

pub type Message {
  Reserve(
    reply_to: process.Subject(Result(Reservation, String)),
    member_id: Uuid,
    lesson_id: Uuid,
  )
  Shutdown
}

pub fn start(
  lesson_id: Uuid,
  starts_at: timestamp.Timestamp,
  reserve: create_reservation.CreateReservation,
  on_shutdown: fn(Uuid) -> Nil,
) -> actor.StartResult(process.Subject(Message)) {
  let deadline = timestamp.subtract(starts_at, duration.minutes(15))
  let now = timestamp.system_time()
  let delay_ms =
    timestamp.difference(now, deadline)
    |> duration.to_milliseconds()

  case delay_ms <= 0 {
    True -> Error(actor.InitFailed("past deadline"))
    False -> {
      use started <- result.try(
        actor.new(ActorState(lesson_id:, on_shutdown:, reserve:))
        |> actor.on_message(handle_message)
        |> actor.start(),
      )
      process.send_after(started.data, delay_ms, Shutdown)
      Ok(started)
    }
  }
}

fn handle_message(
  state: ActorState,
  msg: Message,
) -> actor.Next(ActorState, Message) {
  case msg {
    Shutdown -> {
      state.on_shutdown(state.lesson_id)
      actor.stop()
    }
    Reserve(reply_to:, member_id:, lesson_id:) -> {
      let result =
        state.reserve(member_id, requests.CreateReservationInput(lesson_id:))
      process.send(reply_to, result)
      actor.continue(state)
    }
  }
}
