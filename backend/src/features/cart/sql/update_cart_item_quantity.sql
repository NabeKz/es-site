UPDATE app.cart_items
SET quantity = $2
WHERE id = $1
RETURNING id, member_id, product_id, quantity
