SELECT id
FROM app.reservations
WHERE lesson_id = $1
  AND member_id = $2
LIMIT 1;
