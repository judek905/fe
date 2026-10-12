-- =====================================================================
-- 05 JOINS: combine rows from related tables
-- Picture two circles A (left table) and B (right table):
--   INNER JOIN       only the overlap
--   LEFT JOIN        all of A + matching B (NULL where no match)
--   RIGHT JOIN       all of B + matching A
--   FULL OUTER JOIN  everything from both
--   CROSS JOIN       every A row paired with every B row
-- =====================================================================

-- INNER JOIN: products with their category name
SELECT p.name AS product, c.name AS category, p.price
FROM products p
INNER JOIN categories c ON c.category_id = p.category_id;

-- LEFT JOIN: ALL customers, even those with no orders
SELECT c.first_name, o.order_id, o.status
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id;

-- Find rows with NO match ("anti-join"): customers who never ordered
SELECT c.customer_id, c.first_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Categories with no products
SELECT c.name
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
WHERE p.product_id IS NULL;

-- RIGHT JOIN (same as LEFT with tables swapped)
SELECT c.name AS category, p.name AS product
FROM products p
RIGHT JOIN categories c ON c.category_id = p.category_id;

-- FULL OUTER JOIN
SELECT c.name AS category, p.name AS product
FROM categories c
FULL OUTER JOIN products p ON p.category_id = c.category_id;

-- MULTI-TABLE JOIN: a full order report
SELECT o.order_id,
       cu.first_name || ' ' || cu.last_name AS customer,
       p.name AS product,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers   cu ON cu.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id    = o.order_id
JOIN products    p  ON p.product_id   = oi.product_id
ORDER BY o.order_id, p.name;

-- JOIN + GROUP BY: total spent per customer (including those who spent 0)
SELECT cu.customer_id, cu.first_name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
FROM customers cu
LEFT JOIN orders o       ON o.customer_id = cu.customer_id AND o.status <> 'cancelled'
LEFT JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY cu.customer_id, cu.first_name
ORDER BY total_spent DESC;

-- CROSS JOIN: every size/colour combination, etc.
SELECT c.name AS category, s.size
FROM categories c
CROSS JOIN (VALUES ('S'), ('M'), ('L')) AS s(size)
WHERE c.name = 'Clothing';

-- SELF JOIN: customers living in the same city
SELECT a.first_name AS customer_a, b.first_name AS customer_b, a.city
FROM customers a
JOIN customers b ON a.city = b.city AND a.customer_id < b.customer_id;

-- USING shortcut when column names match
SELECT * FROM orders JOIN order_items USING (order_id);

-- COMMON MISTAKE: forgetting the ON condition (or using the wrong one)
-- creates a huge cartesian product. Always check row counts.
