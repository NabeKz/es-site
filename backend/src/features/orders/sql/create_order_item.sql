INSERT INTO app.order_items (id, order_id, product_id, name, unit_price, quantity)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id, order_id, product_id, name, unit_price, quantity
