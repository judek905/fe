# SQL Practice: SELECT, Aggregates and Joins

Three annotated, runnable SQL scripts that cover the core of querying a relational database: reading and filtering rows, summarising data with `GROUP BY`, and combining tables with joins. Each script is full of comments that explain the ideas and point out common mistakes.

All three files contain only `SELECT` statements, so they never change your data and are safe to run as often as you like.

## Files

| File | Topic | What it covers |
|------|-------|----------------|
| [`03_select_basics.sql`](03_select_basics.sql) | `SELECT` basics | Columns and aliases, `DISTINCT`, `WHERE`, `NULL`, pattern matching, sorting and paging, text / number / date functions, casting, `CASE` |
| [`04_aggregates_group_by.sql`](04_aggregates_group_by.sql) | Aggregates, `GROUP BY`, `HAVING` | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, grouping, `WHERE` vs `HAVING`, `STRING_AGG`, `ARRAY_AGG`, `FILTER`, `ROLLUP`, a monthly revenue report |
| [`05_joins.sql`](05_joins.sql) | Joins | `INNER`, `LEFT`, `RIGHT`, `FULL OUTER` and `CROSS` joins, anti-joins, multi-table joins, joins with `GROUP BY`, self joins, `USING` |

Work through them in numeric order. File 04 refers ahead to the joins in file 05.

## Before you start

**PostgreSQL.** The scripts are written for PostgreSQL and use some of its specific syntax, including `ILIKE`, the `~` regex operator, `::` casts, `FILTER (WHERE ...)`, `STRING_AGG(... ORDER BY ...)`, `ARRAY_AGG`, `DATE_TRUNC` and `TO_CHAR`. On another database, a few queries will need translating.

**Sample data.** The queries run against the sample database built by `01_setup_sample_data.sql`, so run that first. File 04 notes that if you changed data in file 02, you should re-run `01_setup_sample_data.sql` before continuing.

## The sample data

These are the tables and columns the scripts use, worked out from the queries themselves. The full definitions (types, constraints, rows) live in `01_setup_sample_data.sql`.

| Table | Columns used |
|-------|--------------|
| `customers` | `customer_id`, `first_name`, `last_name`, `email`, `city` (may be `NULL`), `country` |
| `categories` | `category_id`, `name` |
| `products` | `product_id`, `name`, `price`, `stock`, `is_active`, `category_id` |
| `orders` | `order_id`, `customer_id`, `order_date`, `status` (e.g. `'delivered'`, `'cancelled'`) |
| `order_items` | `order_id`, `product_id`, `quantity`, `unit_price` |

How the tables connect (the join conditions used in file 05):

- `products.category_id` → `categories.category_id`
- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`

## Running the scripts

From the command line with `psql`:

```bash
psql -d <your_database> -f 01_setup_sample_data.sql   # build or reset the sample data
psql -d <your_database> -f 03_select_basics.sql       # run a whole lesson file
```

Or from inside `psql`: `\i 03_select_basics.sql`

The files are written to be read and run **one query at a time**. Paste a statement into `psql`, pgAdmin, DBeaver or any other SQL client, run it, and compare what you get with the comment above it. Running a whole file prints every result in sequence, which is a lot to scroll through.

## What each file covers

### 03: SELECT basics

- **Execution order.** SQL logically runs a query as `FROM` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `DISTINCT` → `ORDER BY` → `LIMIT`. That is why a column alias works in `ORDER BY` but not in `WHERE`.
- **Filtering.** Comparisons, `BETWEEN` (inclusive), `IN` / `NOT IN`, and combining conditions with `AND`, `OR` and `NOT`.
- **NULL** means "unknown". Test for it with `IS NULL` / `IS NOT NULL`, never `= NULL`. `COALESCE` replaces a NULL with a default, and `NULLIF` turns a chosen value into NULL.
- **Pattern matching.** `LIKE` (`%` is any run of characters, `_` is exactly one), `ILIKE` for case-insensitive matches, and `~` for regular expressions.
- **Sorting and paging.** `ORDER BY` with several keys, `LIMIT` for a top-N, and `LIMIT` with `OFFSET` for pages.
- **Functions.** Text (`UPPER`, `LOWER`, `LENGTH`, `||`, `SUBSTRING`, `TRIM`, `REPLACE`), numbers (`ROUND`, `CEIL`, `FLOOR`, `ABS`, `MOD`, `POWER`), dates (`CURRENT_DATE`, `EXTRACT`, `TO_CHAR`, `DATE_TRUNC`, date and interval arithmetic) and casting (`CAST`, `::`).
- **CASE** for if/else logic, for example sorting products into Premium, Mid and Budget price tiers.

### 04: Aggregates, GROUP BY, HAVING

- **Counting.** `COUNT(*)` counts rows, `COUNT(column)` counts non-NULL values only, and `COUNT(DISTINCT column)` counts unique values.
- **Summaries.** `SUM`, `AVG`, `MIN`, `MAX` and `ROUND`.
- **GROUP BY** gives one result row per group. Every column in `SELECT` must either appear in `GROUP BY` or be inside an aggregate.
- **WHERE vs HAVING.** `WHERE` filters rows before grouping; `HAVING` filters groups after grouping.
- **Extra aggregates.** `STRING_AGG` (joins values into one string), `ARRAY_AGG` (collects values into an array) and `COUNT(*) FILTER (WHERE ...)` for conditional counts.
- **ROLLUP** adds subtotals and a grand total.
- **Reports.** Revenue per order, and a monthly report that joins `orders` to `order_items`, skips cancelled orders and groups by `DATE_TRUNC('month', ...)`. It counts `DISTINCT order_id` because the join repeats each order once per line item.

### 05: Joins

| Join | Returns |
|------|---------|
| `INNER JOIN` | Only the rows that match in both tables |
| `LEFT JOIN` | All rows from the left table, plus matching rows from the right (NULL where there is no match) |
| `RIGHT JOIN` | All rows from the right table, plus matching rows from the left |
| `FULL OUTER JOIN` | Everything from both tables |
| `CROSS JOIN` | Every left row paired with every right row |

A `RIGHT JOIN` is just a `LEFT JOIN` with the two tables swapped.

- **Anti-join.** `LEFT JOIN ... WHERE right_table.key IS NULL` finds rows with no match: customers who never ordered, categories with no products.
- **Multi-table join.** A full order report that links orders, customers, order items and products and calculates a line total.
- **Join plus GROUP BY.** Total spent per customer, including customers who spent nothing. The `status <> 'cancelled'` test sits in the `ON` clause rather than `WHERE`, so customers with no qualifying orders are kept, and `COALESCE(..., 0)` turns their missing total into 0.
- **CROSS JOIN** with a `VALUES` list, pairing the `'Clothing'` category with each size (S, M, L).
- **Self join.** Customers who live in the same city. The `a.customer_id < b.customer_id` condition stops a customer being paired with themselves and stops each pair appearing twice.
- **USING.** A shortcut when both tables share the join column name.

## Mistakes these scripts warn about

- Writing `= NULL` instead of `IS NULL`.
- Selecting a column that is neither in `GROUP BY` nor inside an aggregate.
- Putting a condition on groups in `WHERE` (it belongs in `HAVING`), or a plain row filter in `HAVING`.
- Forgetting the `ON` condition, or getting it wrong, which produces a huge cartesian product. Always check row counts.
- Using `SELECT *` in real applications. It is fine for exploring.

## If something does not work

- **A syntax error on `ILIKE`, `::`, `FILTER` or similar.** You are probably not connected to PostgreSQL.
- **An empty result.** Some examples filter on specific values, such as the `'Clothing'` category, the `'delivered'` and `'cancelled'` statuses, or `category_id` 1 and 3. If your data differs or has been modified, re-run `01_setup_sample_data.sql`.
- **A "must appear in the GROUP BY clause" error.** See the `GROUP BY` rule under file 04.
