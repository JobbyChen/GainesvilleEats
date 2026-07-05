-- 02_best_budget_by_cuisine.sql
-- For each cuisine, pick the best budget option combining low price and good rating.

WITH avg_rest AS (
  SELECT
    r.id AS restaurant_id,
    r.name,
    COALESCE(r.cuisine, 'Unknown') AS cuisine,
    ROUND(AVG(mi.price),2) AS avg_price,
    ROUND(AVG(rv.rating),2) AS avg_rating,
    COUNT(rv.id) AS review_count
  FROM restaurants r
  LEFT JOIN menu_items mi ON mi.restaurant_id = r.id
  LEFT JOIN reviews rv ON rv.restaurant_id = r.id
  GROUP BY r.id, r.name, r.cuisine
),
scored AS (
  SELECT
    restaurant_id,
    name,
    cuisine,
    avg_price,
    avg_rating,
    review_count,
    CASE WHEN avg_price IS NULL OR avg_price <= 0 THEN NULL ELSE (CAST(avg_rating AS REAL) / avg_price) END AS value_score
  FROM avg_rest
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY cuisine ORDER BY value_score DESC NULLS LAST, avg_price ASC) AS rn
  FROM scored
)
SELECT cuisine, restaurant_id, name, avg_price, avg_rating, review_count
FROM ranked
WHERE rn = 1
ORDER BY cuisine;
