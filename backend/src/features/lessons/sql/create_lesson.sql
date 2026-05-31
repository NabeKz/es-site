INSERT INTO app.lessons
  (id, name, instructor, starts_at, ends_at, capacity, description)
VALUES
  ($1, $2, $3, $4, $5, $6, $7)
RETURNING
  id, name, instructor, starts_at, ends_at, capacity, description
