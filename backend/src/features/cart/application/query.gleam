import generated/responses.{type CartItem}
import youid/uuid.{type Uuid}

pub type GetCartItems =
  fn(Uuid) -> Result(List(CartItem), String)
