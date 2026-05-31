import features/reservations/application/command
import features/reservations/application/query

pub type CreateReservation =
  command.CreateReservation

pub type SaveReservation =
  command.SaveReservation

pub type Cancel =
  command.Cancel

pub type ReadReservationInfo =
  command.ReadReservationInfo

pub type DeleteReservation =
  command.DeleteReservation

pub type ReadLessonForCancel =
  command.ReadLessonForCancel

pub type ListMyReservations =
  query.ListMyReservations

pub type ListMyReservationsAdaptor =
  query.ListMyReservationsAdaptor

pub const create = command.create

pub const cancel = command.cancel

pub const list_my = query.list_my
