import gleam/erlang/process
import gleam/otp/actor
import gleam/string
import pog

import shared/env

pub fn start() -> pog.Connection {
  let database_url = case env.get("DATABASE_URL") {
    Ok(url) -> url
    Error(Nil) -> panic as "DATABASE_URL is not set"
  }

  let pool_name = process.new_name("db_pool")
  let assert Ok(config) = pog.url_config(pool_name, database_url)
  let config = with_neon_endpoint(config)
  let assert Ok(actor.Started(_, conn)) = pog.start(config)
  conn
}

// Neon requires the endpoint ID as a connection parameter because epgsql
// doesn't support SNI. Extracts the endpoint ID from the host (e.g.
// "ep-cold-heart-abc123-pooler.region.aws.neon.tech" → "ep-cold-heart-abc123").
fn with_neon_endpoint(config: pog.Config) -> pog.Config {
  case string.contains(config.host, "neon.tech") {
    False -> config
    True ->
      case string.split(config.host, ".") {
        [first_segment, ..] -> {
          let endpoint_id = case string.split(first_segment, "-pooler") {
            [id, ..] -> id
            _ -> first_segment
          }
          pog.connection_parameter(
            config,
            name: "options",
            value: "endpoint=" <> endpoint_id,
          )
        }
        _ -> config
      }
  }
}
