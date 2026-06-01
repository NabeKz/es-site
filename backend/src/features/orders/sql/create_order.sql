INSERT INTO app.orders (id, member_id, total_price, created_at)
VALUES ($1, $2, $3, $4)
RETURNING id, member_id, total_price, created_at
