SELECT id, member_id, token
FROM app.sessions
WHERE token = $1
