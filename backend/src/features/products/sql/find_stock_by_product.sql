SELECT COALESCE(SUM(delta), 0)::int AS stock
FROM app.stock_movements
WHERE product_id = $1
