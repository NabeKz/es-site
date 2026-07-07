import features/payments/application/command
import features/payments/sql
import gleam/time/timestamp
import pog
import shared/db as repo
import youid/uuid.{type Uuid}

fn do_save(db: pog.Connection, order_id: Uuid, amount: Int) -> Result(Nil, String) {
  let now = timestamp.system_time()
  use _ <- repo.query(
    run: fn() { db |> sql.create_payment(uuid.v4(), order_id, amount, now) },
    on_error: "Failed to save payment",
  )
  Ok(Nil)
}

pub fn save(db: pog.Connection) -> command.SavePayment {
  fn(order_id, amount) { do_save(db, order_id, amount) }
}
