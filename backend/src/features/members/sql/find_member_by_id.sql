SELECT id, email, password_hash, salt
FROM app.members
WHERE id = $1
