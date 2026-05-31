import gleam/time/timestamp

pub fn now() -> timestamp.Timestamp {
  timestamp.system_time()
}
