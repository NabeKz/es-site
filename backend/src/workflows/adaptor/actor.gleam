import gleam/erlang/process
import gleam/result
import youid/uuid.{type Uuid}

import generated/requests
import generated/responses.{type Reservation}
import workflows/create_reservation
import workflows/lesson_reservation_actor
import workflows/reservation_supervisor

pub fn create(
  sup: reservation_supervisor.ReservationSupervisor,
) -> create_reservation.CreateReservation {
  fn(member_id, input) { do_create(sup, member_id, input) }
}

fn do_create(
  sup: reservation_supervisor.ReservationSupervisor,
  member_id: Uuid,
  input: requests.CreateReservationInput,
) -> Result(Reservation, String) {
  use subject <- result.try(
    reservation_supervisor.find_actor(sup, input.lesson_id),
  )
  let reply = process.new_subject()
  process.send(
    subject,
    lesson_reservation_actor.Reserve(
      reply_to: reply,
      member_id:,
      lesson_id: input.lesson_id,
    ),
  )
  case process.receive(reply, 5000) {
    Error(Nil) -> Error("not available")
    Ok(result) -> result
  }
}
