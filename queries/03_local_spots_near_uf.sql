-- 03_local_spots_near_uf.sql
-- Finds restaurants within a radius (miles) of UF campus using a precomputed nearby_restaurants table.
-- This query expects scripts/compute_nearby.py to populate a table named `nearby_restaurants` with columns:
-- (restaurant_id INTEGER, name TEXT, distance_miles REAL)

WITH avg_price AS (
  SELECT restaurant_id, ROUND(AVG(price),2) AS avg_price
  FROM menu_items
  WHERE price IS NOT NULL
  GROUP BY restaurant_id
)
SELECT nr.restaurant_id, nr.name, ROUND(nr.distance_miles,2) AS distance_miles, ap.avg_price
FROM nearby_restaurants nr
LEFT JOIN avg_price ap ON ap.restaurant_id = nr.restaurant_id
ORDER BY nr.distance_miles ASC, COALESCE(ap.avg_price, 9999) ASC
LIMIT 50;
