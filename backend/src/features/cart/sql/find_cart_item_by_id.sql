SELECT id, member_id, product_id, quantity
FROM app.cart_items
WHERE id = $1
