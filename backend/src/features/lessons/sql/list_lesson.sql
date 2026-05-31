SELECT
  l.id,
  l.name,
  l.instructor,
  l.starts_at,
  l.ends_at,
  l.capacity,
  COUNT(r.id)::int AS reserved_count,
  l.description
FROM app.lessons l
LEFT JOIN app.reservations r ON r.lesson_id = l.id
WHERE l.starts_at > $1
GROUP BY l.id
ORDER BY l.starts_at ASC
