SELECT
  l.capacity,
  COUNT(r.id)::int AS reserved_count
FROM app.lessons l
LEFT JOIN app.reservations r ON r.lesson_id = l.id
WHERE l.id = $1
GROUP BY l.capacity;
