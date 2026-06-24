INSERT INTO app.admin_sessions (id, admin_id, token, created_at)
VALUES ($1, $2, $3, $4)
RETURNING id, admin_id, token
