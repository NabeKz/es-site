WITH locked AS (
  SELECT pg_advisory_xact_lock(hashtext($1::text))
)
SELECT 1 AS ok
