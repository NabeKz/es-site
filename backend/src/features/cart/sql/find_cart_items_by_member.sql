SELECT ci.id, ci.product_id, p.name, p.price, ci.quantity
FROM app.cart_items ci
JOIN app.products p ON ci.product_id = p.id
WHERE ci.member_id = $1
