// User Story: 会員として、空きのあるレッスンを予約したい

import generated/requests.{CreateReservationInput}
import generated/responses.{Reservation}
import gleeunit/should
import workflows/create_reservation
import youid/uuid

fn fixture_lesson(capacity: Int, reserved_count: Int) {
  create_reservation.LessonInfo(capacity:, reserved_count:)
}

// test: 空きがある場合は予約を作成できる
pub fn create_reservation_success_test() {
  let lesson_id = uuid.v4()
  let member_id = uuid.v4()
  let input = CreateReservationInput(lesson_id:)
  let get_lesson = fn(_) { Ok(fixture_lesson(10, 5)) }
  let has_reservation = fn(_, _) { Ok(False) }
  let save = fn(_: create_reservation.ReservationInfo) {
    Ok(Reservation(id: uuid.v4(), lesson_id: lesson_id))
  }

  create_reservation.create(get_lesson, has_reservation, save)(member_id, input)
  |> should.be_ok
}

// test: 満席のレッスンは予約できない
pub fn create_reservation_full_test() {
  let input = CreateReservationInput(lesson_id: uuid.v4())
  let get_lesson = fn(_) { Ok(fixture_lesson(10, 10)) }
  let has_reservation = fn(_, _) { Ok(False) }
  let save = fn(_: create_reservation.ReservationInfo) { Error("unreachable") }

  create_reservation.create(get_lesson, has_reservation, save)(uuid.v4(), input)
  |> should.equal(Error("full"))
}

// test: 同じレッスンを二重予約できない
pub fn create_reservation_duplicate_test() {
  let input = CreateReservationInput(lesson_id: uuid.v4())
  let get_lesson = fn(_) { Ok(fixture_lesson(10, 5)) }
  let has_reservation = fn(_, _) { Ok(True) }
  let save = fn(_: create_reservation.ReservationInfo) { Error("unreachable") }

  create_reservation.create(get_lesson, has_reservation, save)(uuid.v4(), input)
  |> should.equal(Error("already reserved"))
}

// test: 存在しないレッスンは予約できない
pub fn create_reservation_lesson_not_found_test() {
  let input = CreateReservationInput(lesson_id: uuid.v4())
  let get_lesson = fn(_) { Error("not found") }
  let has_reservation = fn(_, _) { Ok(False) }
  let save = fn(_: create_reservation.ReservationInfo) { Error("unreachable") }

  create_reservation.create(get_lesson, has_reservation, save)(uuid.v4(), input)
  |> should.be_error
}

// test: DB エラー時は Error を返す
pub fn create_reservation_save_error_test() {
  let input = CreateReservationInput(lesson_id: uuid.v4())
  let get_lesson = fn(_) { Ok(fixture_lesson(10, 5)) }
  let has_reservation = fn(_, _) { Ok(False) }
  let save = fn(_: create_reservation.ReservationInfo) { Error("db error") }

  create_reservation.create(get_lesson, has_reservation, save)(uuid.v4(), input)
  |> should.be_error
}
