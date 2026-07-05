-- 04_best_value_restaurants.sql
-- Rank restaurants by value_score = avg_rating / avg_price

WITH stats AS (
  SELECT r.id AS restaurant_id, r.name,
         ROUND(AVG(mi.price),2) AS avg_price,
         ROUND(AVG(rv.rating),2) AS avg_rating,
         COUNT(rv.id) AS review_count
  FROM restaurants r
  LEFT JOIN menu_items mi ON mi.restaurant_id = r.id
  LEFT JOIN reviews rv ON rv.restaurant_id = r.id
  GROUP BY r.id, r.name
)
SELECT restaurant_id, name, avg_rating, avg_price,
       ROUND(CASE WHEN avg_price > 0 THEN avg_rating / avg_price ELSE NULL END, 4) AS value_score,
       review_count
FROM stats
WHERE avg_price IS NOT NULL AND avg_rating IS NOT NULL
ORDER BY value_score DESC
LIMIT 50;
