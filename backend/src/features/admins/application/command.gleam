import domain/admin.{type AdminRecord}
import gleam/time/timestamp
import youid/uuid

pub type SaveAdmin =
  fn(AdminRecord, timestamp.Timestamp) -> Result(AdminRecord, String)

pub type FindAdminByEmail =
  fn(String) -> Result(AdminRecord, String)

pub type FindAdminById =
  fn(uuid.Uuid) -> Result(AdminRecord, String)
