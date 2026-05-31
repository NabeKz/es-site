import youid/uuid

pub type MemberRecord {
  MemberRecord(
    id: uuid.Uuid,
    email: String,
    password_hash: String,
    salt: String,
  )
}
