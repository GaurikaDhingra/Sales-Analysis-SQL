-- STREAMCART PROJECT - DATA PROFILING & DATA CLEANING

USE streamcart;

SET SQL_SAFE_UPDATES = 0;

-- STEP 1 : UNDERSTANDING THE DATA 
DESCRIBE orders;

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_subscriptions FROM subscriptions;
SELECT COUNT(*) AS total_support_tickets FROM support_tickets;

-- STEP 2 : SAMPLE DATA REVIEW
SELECT * FROM customers LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM subscriptions LIMIT 10;
SELECT * FROM support_tickets LIMIT 10;

-- STEP 3 : NULL VALUE ANALYSIS
-- CUSTOMERS
SELECT COUNT(*) AS total_rows,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS signup_date_nulls,
SUM(CASE WHEN is_active IS NULL THEN 1 ELSE 0 END) AS is_active_nulls
FROM customers;

-- PRODUCTS
SELECT COUNT(*) AS total_rows,
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_nulls,
SUM(CASE WHEN cost_price IS NULL THEN 1 ELSE 0 END) AS cost_price_nulls,
SUM(CASE WHEN selling_price IS NULL THEN 1 ELSE 0 END) AS selling_price_nulls
FROM products;

-- ORDERS
SELECT COUNT(*) AS total_rows,
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_nulls,
SUM(CASE WHEN discount_pct IS NULL THEN 1 ELSE 0 END) AS discount_nulls,
SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS channel_nulls
FROM orders;

-- SUBSCRIPTIONS
SELECT COUNT(*) AS total_rows,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
SUM(CASE WHEN plan_name IS NULL THEN 1 ELSE 0 END) AS plan_name_nulls,
SUM(CASE WHEN monthly_fee IS NULL THEN 1 ELSE 0 END) AS monthly_fee_nulls,
SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method_nulls
FROM subscriptions;

-- SUPPORT TICKETS
SELECT COUNT(*) AS total_rows,
SUM(CASE WHEN ticket_id IS NULL THEN 1 ELSE 0 END) AS ticket_id_nulls,
SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_nulls,
SUM(CASE WHEN priority IS NULL THEN 1 ELSE 0 END) AS priority_nulls,
SUM(CASE WHEN csat_score IS NULL THEN 1 ELSE 0 END) AS csat_score_nulls
FROM support_tickets;

-- STEP 4 : BLANK VALUE CHECKS
SELECT * FROM customers WHERE city = '';
SELECT * FROM customers WHERE customer_name = '';
SELECT * FROM products WHERE product_name = '';
SELECT * FROM products WHERE category = '';
SELECT * FROM subscriptions WHERE plan_name = '';
SELECT * FROM subscriptions WHERE payment_method = '';
SELECT * FROM support_tickets WHERE category = '';
SELECT * FROM support_tickets WHERE priority = '';

-- STEP 5 : DISTINCT VALUE AUDIT
SELECT DISTINCT category FROM products;
SELECT DISTINCT channel FROM orders;
SELECT DISTINCT payment_method FROM subscriptions;
SELECT DISTINCT priority FROM support_tickets;
SELECT DISTINCT city FROM customers;
SELECT DISTINCT country FROM customers;

-- STEP 6 : DUPLICATE RECORD CHECK
/* Customers */
SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- FROM
-- WHERE
-- GROUP BY
-- HAVING
-- SELECT
-- ORDER BY

-- WHERE -> Individual Rows
-- HAVING -> Groups

/* Products */
SELECT product_id,
COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

/* Orders */
SELECT
order_id,
COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

/* Support Tickets */
SELECT
ticket_id,
COUNT(*) AS duplicate_count
FROM support_tickets
GROUP BY ticket_id
HAVING COUNT(*) > 1;

-- STEP 7 : INVALID DATA CHECKS
/* Negative Quantity */
SELECT *
FROM orders
WHERE quantity <= 0;

/* Negative Unit Price */
SELECT *
FROM orders
WHERE unit_price <= 0;

/* Invalid Discount */
SELECT *
FROM orders
WHERE discount_pct > 100
OR discount_pct < 0;

/* Invalid Product Cost */
SELECT *
FROM products
WHERE cost_price <= 0;

/* Invalid Selling Price */
SELECT *
FROM products
WHERE selling_price <= 0;

/* Invalid Subscription Fee */
SELECT *
FROM subscriptions
WHERE monthly_fee <= 0;

/* Invalid CSAT */
SELECT *
FROM support_tickets
WHERE csat_score < 0
OR csat_score > 5;

-- STEP 8 : REFERENTIAL INTEGRITY CHECK
/* Orders without Customers */
SELECT *
FROM orders o LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

/* Orders without Products */
SELECT *
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

/* Subscriptions without Customers */
SELECT *
FROM subscriptions s
LEFT JOIN customers c
ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- STEP 9 : DATA CLEANING QUERIES
/* Replace NULL Discounts */
-- UPDATE orders
-- SET discount_pct = 0 WHERE discount_pct IS NULL;

-- /* Standardize Product Categories */
-- UPDATE products
-- SET category = PROPER(TRIM(category));

-- REMOVE BLANK STRINGS 
-- CUSTOMERS 
DELETE FROM customers
WHERE
IFNULL(TRIM(customer_name),'') = ''
AND IFNULL(TRIM(email),'') = ''
AND IFNULL(TRIM(city),'') = ''
AND IFNULL(TRIM(country),'') = '';

-- PRODUCTS
DELETE FROM products
WHERE
IFNULL(TRIM(product_name),'') = ''
AND IFNULL(TRIM(category),'') = '';

-- ORDERS
DELETE FROM orders
WHERE
customer_id IS NULL
AND product_id IS NULL
AND quantity IS NULL
AND unit_price IS NULL;

-- SUBSCRIPTIONS
DELETE FROM subscriptions
WHERE
customer_id IS NULL
AND IFNULL(TRIM(plan_name),'') = ''
AND monthly_fee IS NULL
AND IFNULL(TRIM(payment_method),'') = '';

-- SUPPORT TICKETS
DELETE FROM support_tickets
WHERE
customer_id IS NULL
AND IFNULL(TRIM(category),'') = ''
AND IFNULL(TRIM(priority),'') = ''
AND csat_score IS NULL;