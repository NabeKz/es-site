import generated/responses.{type Reservation}
import youid/uuid

pub type ListMyReservationsAdaptor =
  fn(uuid.Uuid) -> Result(List(Reservation), String)

pub type ListMyReservations =
  fn(uuid.Uuid) -> Result(List(Reservation), String)

pub fn list_my(adaptor: ListMyReservationsAdaptor) -> ListMyReservations {
  fn(member_id) { adaptor(member_id) }
}
