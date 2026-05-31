SELECT
    r.id,
    r.lesson_id
FROM
    app.reservations r
WHERE
    r.member_id = $1;
