INSERT INTO app.admins (id, email, password_hash, salt, created_at)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, email, password_hash, salt
