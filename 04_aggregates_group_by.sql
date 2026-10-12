-- =====================================================================
-- 04 AGGREGATES, GROUP BY, HAVING
-- (Re-run 01_setup_sample_data.sql first if you changed data in file 02)
-- =====================================================================

SELECT COUNT(*)            FROM products;              -- counts rows
SELECT COUNT(city)         FROM customers;             -- counts NON-NULL values only
SELECT COUNT(DISTINCT country) FROM customers;
SELECT SUM(stock), AVG(price), MIN(price), MAX(price) FROM products;
SELECT ROUND(AVG(price), 2) FROM products WHERE is_active;

-- ---------- GROUP BY: one result row per group ----------
SELECT country, COUNT(*) AS customers
FROM customers
GROUP BY country
ORDER BY customers DESC;

SELECT category_id, COUNT(*) AS products, ROUND(AVG(price),2) AS avg_price, MAX(price) AS most_expensive
FROM products
GROUP BY category_id;

-- RULE: every column in SELECT must be in GROUP BY or inside an aggregate.

-- ---------- WHERE vs HAVING ----------
-- WHERE filters ROWS before grouping. HAVING filters GROUPS after grouping.
SELECT category_id, COUNT(*) AS products
FROM products
WHERE is_active = TRUE            -- row filter
GROUP BY category_id
HAVING COUNT(*) >= 2;             -- group filter

-- ---------- Revenue per order (aggregates over a join, see file 05) ----------
SELECT order_id, SUM(quantity * unit_price) AS order_total, SUM(quantity) AS items
FROM order_items
GROUP BY order_id
ORDER BY order_total DESC;

-- ---------- Extra aggregates ----------
SELECT STRING_AGG(name, ', ' ORDER BY name) AS product_names FROM products WHERE category_id = 1;
SELECT category_id, ARRAY_AGG(name) FROM products GROUP BY category_id;
SELECT COUNT(*) FILTER (WHERE status = 'delivered') AS delivered,
       COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled
FROM orders;

-- ---------- GROUPING SETS / ROLLUP (subtotals + grand total) ----------
SELECT country, city, COUNT(*)
FROM customers
GROUP BY ROLLUP (country, city)
ORDER BY country, city;

-- ---------- Monthly report ----------
SELECT DATE_TRUNC('month', o.order_date) AS month,
       COUNT(DISTINCT o.order_id)        AS orders,
       SUM(oi.quantity * oi.unit_price)  AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY 1
ORDER BY 1;
