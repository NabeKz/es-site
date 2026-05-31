SELECT
    id,
    lesson_id,
    member_id
FROM
    app.reservations
WHERE
    id = $1;
