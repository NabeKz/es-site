SELECT id, admin_id, token
FROM app.admin_sessions
WHERE token = $1
