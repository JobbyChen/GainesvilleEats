-- 05_family_owned_options.sql
-- List family-owned restaurants sorted by avg_price (cheapest first)

WITH fam AS (
  SELECT r.id AS restaurant_id, r.name, COALESCE(r.neighborhood, '') AS neighborhood,
         ROUND(AVG(mi.price),2) AS avg_price,
         ROUND(AVG(rv.rating),2) AS avg_rating
  FROM restaurants r
  LEFT JOIN menu_items mi ON mi.restaurant_id = r.id
  LEFT JOIN reviews rv ON rv.restaurant_id = r.id
  WHERE COALESCE(r.family_owned, 0) = 1
  GROUP BY r.id, r.name, r.neighborhood
)
SELECT restaurant_id, name, neighborhood, avg_price, avg_rating
FROM fam
ORDER BY avg_price ASC
LIMIT 50;
