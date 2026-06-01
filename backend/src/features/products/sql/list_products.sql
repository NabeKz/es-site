SELECT p.id, p.name, p.price, COALESCE(SUM(sm.delta), 0)::int AS stock, p.description
FROM app.products p
LEFT JOIN app.stock_movements sm ON p.id = sm.product_id
GROUP BY p.id
