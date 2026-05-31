SELECT id, email, password_hash, salt
FROM app.members
WHERE email = $1
