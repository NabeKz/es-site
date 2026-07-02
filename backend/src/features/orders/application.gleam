import features/orders/application/command

pub type FetchCartItems =
  command.FetchCartItems

pub type SaveOrder =
  command.SaveOrder

pub type Accept =
  command.Accept

pub type AcceptedOrder =
  command.AcceptedOrder

pub type OrderStatus =
  command.OrderStatus

pub const accept = command.accept
