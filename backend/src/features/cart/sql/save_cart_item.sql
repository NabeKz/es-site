INSERT INTO app.cart_items (id, member_id, product_id, quantity)
VALUES ($1, $2, $3, $4)
RETURNING id, member_id, product_id, quantity
