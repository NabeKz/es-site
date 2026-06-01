SELECT id, member_id, product_id, quantity
FROM app.cart_items
WHERE member_id = $1
  AND product_id = $2
