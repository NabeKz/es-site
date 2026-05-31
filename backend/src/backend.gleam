import gleam/erlang/process
import gleam/result
import mist
import shared/env
import wisp
import wisp/wisp_mist

import app/db
import app/router
import compose
import workflows/reservation_supervisor

pub fn main() {
  wisp.configure_logger()

  let conn = db.start()
  let pepper = env.get("PASSWORD_PEPPER") |> result.unwrap("")

  let assert Ok(sup) = reservation_supervisor.start(conn)
  compose.restore_actors(conn, sup)
  let handler = compose.build(conn, pepper, sup)

  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handler
    |> router.handle_request()
    |> wisp_mist.handler(secret_key_base)
    |> mist.new()
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}
