-- 01_cheapest_restaurants.sql
-- Restaurants with the lowest average menu price (exclude restaurants with no menu items)

WITH avg_prices AS (
  SELECT
    r.id AS restaurant_id,
    r.name,
    ROUND(AVG(mi.price), 2) AS avg_price,
    COUNT(mi.id) AS menu_item_count
  FROM restaurants r
  JOIN menu_items mi ON mi.restaurant_id = r.id
  WHERE mi.price IS NOT NULL
  GROUP BY r.id, r.name
)
SELECT restaurant_id, name, avg_price, menu_item_count
FROM avg_prices
ORDER BY avg_price ASC, menu_item_count DESC
LIMIT 50;
