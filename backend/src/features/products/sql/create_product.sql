INSERT INTO app.products (id, name, price, description)
VALUES ($1, $2, $3, $4)
RETURNING id, name, price, description
