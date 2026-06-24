SELECT id, email, password_hash, salt
FROM app.admins
WHERE email = $1
