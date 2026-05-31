// User Story: 会員として、レッスンを予約したい（requirements.md）

import features/reservations/application/command
import generated/requests.{CreateReservationInput}
import generated/responses.{Reservation}
import gleeunit/should
import youid/uuid

// test: 予約を正常に作成できる
pub fn create_reservation_success_test() {
  let lesson_id = uuid.v4()
  let member_id = uuid.v4()
  let input = CreateReservationInput(lesson_id:)
  let save = fn(_: command.ReservationInfo) { Ok(Reservation(id: uuid.v4(), lesson_id: lesson_id)) }

  let assert Ok(reservation) = command.create(save)(member_id, input)

  // id は lesson_id とは別の新しい UUID であること
  reservation.id |> should.not_equal(lesson_id)
}

// test: DB エラー時は Error を返す
pub fn create_reservation_adaptor_error_test() {
  let input = CreateReservationInput(lesson_id: uuid.v4())
  let save = fn(_: command.ReservationInfo) { Error("db error") }

  command.create(save)(uuid.v4(), input) |> should.be_error
}
