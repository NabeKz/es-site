import youid/uuid.{type Uuid}

pub type SavePayment =
  fn(Uuid, Int) -> Result(Nil, String)

pub type Pay =
  fn(Uuid, Int) -> Result(Nil, String)

/// 決済する（モック）。外部決済ゲートウェイは持たず、`payments` への記録をもって
/// 決済済みとみなす（差し替え可能な seam。決済モックの間は補償ランタイムは最小でよい）。
pub fn pay(save: SavePayment) -> Pay {
  fn(order_id, amount) { save(order_id, amount) }
}
