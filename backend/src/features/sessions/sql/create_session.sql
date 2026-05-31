INSERT INTO app.sessions (id, member_id, token, created_at)
VALUES ($1, $2, $3, $4)
RETURNING id, member_id, token
