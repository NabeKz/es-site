import gleam/result
import generated/requests
import generated/responses.{type Reservation}
import youid/uuid

pub type LessonInfo {
  LessonInfo(capacity: Int, reserved_count: Int)
}

pub type ReservationInfo {
  ReservationInfo(id: uuid.Uuid, lesson_id: uuid.Uuid, member_id: uuid.Uuid)
}

pub type GetLesson =
  fn(uuid.Uuid) -> Result(LessonInfo, String)

pub type HasReservation =
  fn(uuid.Uuid, uuid.Uuid) -> Result(Bool, String)

pub type SaveReservation =
  fn(ReservationInfo) -> Result(Reservation, String)

pub type CreateReservation =
  fn(uuid.Uuid, requests.CreateReservationInput) -> Result(Reservation, String)

pub fn create(
  get_lesson: GetLesson,
  has_reservation: HasReservation,
  save: SaveReservation,
) -> CreateReservation {
  fn(member_id, input) { do_create(get_lesson, has_reservation, save, member_id, input) }
}

fn do_create(
  get_lesson: GetLesson,
  has_reservation: HasReservation,
  save: SaveReservation,
  member_id: uuid.Uuid,
  input: requests.CreateReservationInput,
) -> Result(Reservation, String) {
  use lesson <- result.try(get_lesson(input.lesson_id))
  use is_dup <- result.try(has_reservation(input.lesson_id, member_id))
  use _ <- result.try(check_not_duplicate(is_dup))
  use _ <- result.try(check_capacity(lesson))
  save(ReservationInfo(id: uuid.v4(), lesson_id: input.lesson_id, member_id:))
}

fn check_not_duplicate(is_duplicate: Bool) -> Result(Nil, String) {
  case is_duplicate {
    False -> Ok(Nil)
    True -> Error("already reserved")
  }
}

fn check_capacity(lesson: LessonInfo) -> Result(Nil, String) {
  case lesson.capacity - lesson.reserved_count > 0 {
    True -> Ok(Nil)
    False -> Error("full")
  }
}
