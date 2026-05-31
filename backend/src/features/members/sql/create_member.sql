INSERT INTO app.members (id, email, password_hash, salt)
VALUES ($1, $2, $3, $4)
RETURNING id, email, password_hash, salt
