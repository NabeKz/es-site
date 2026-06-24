import youid/uuid

pub type AdminRecord {
  AdminRecord(
    id: uuid.Uuid,
    email: String,
    password_hash: String,
    salt: String,
  )
}
