
USE RetailDB;
GO

/* ==========================================
   SET 1 - RETAIL SALES REPORTING
   ========================================== */


/* 1. TOP 5 PRODUCTS BY REVENUE */

SELECT TOP 5
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;


/* 2. MONTH-WISE SALES */

SELECT
    FORMAT(o.order_date, 'yyyy-MM') AS sales_month,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS monthly_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_date, 'yyyy-MM')
ORDER BY sales_month;


/* 3. CUSTOMERS WITH MORE THAN THREE ORDERS */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 3;


/* 4. AVERAGE BASKET VALUE PER CITY */

SELECT
    c.city,
    ROUND(
        AVG(order_total),
        2
    ) AS average_basket_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) basket
    ON o.order_id = basket.order_id
GROUP BY c.city
ORDER BY average_basket_value DESC;


/* 5. ORDERS WITHOUT PAYMENT (LEFT JOIN) */

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.payment_status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;


/* 6. CUSTOMERS WITH NO ORDERS */

SELECT
    c.customer_id,
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


/* 7. PRODUCT CATEGORY REVENUE SHARE */

SELECT
    p.category,
    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS category_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100.0 /
        (SELECT SUM(quantity * unit_price)
         FROM order_items),
        2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;


/* 8. DAY WITH HIGHEST SALES */

SELECT TOP 1
    o.order_date,
    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS daily_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_date
ORDER BY daily_sales DESC;


/* ==========================================
   CUSTOMER-FRIENDLY OUTPUT
   STRING, DATE AND MATHEMATICAL FUNCTIONS
   ========================================== */

SELECT
    UPPER(c.customer_name) AS customer_name,
    CONCAT(c.city, ' - ', c.customer_name) AS customer_details,
    FORMAT(o.order_date, 'dd-MMM-yyyy') AS formatted_order_date,
    DATEDIFF(DAY, o.order_date, GETDATE()) AS days_since_order,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_amount
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_name,
    c.city,
    o.order_date,
    o.order_id
ORDER BY o.order_date;


/* ==========================================
   NULL BEHAVIOUR
   ========================================== */

-- COUNT(*) counts all rows
-- COUNT(payment_status) ignores NULL values
-- AVG ignores NULL values

SELECT
    COUNT(*) AS total_orders,
    COUNT(payment_status) AS non_null_payment_status,
    AVG(CAST(
        CASE
            WHEN payment_status = 'Paid' THEN 1.0
            ELSE 0.0
        END AS FLOAT
    )) AS paid_order_ratio
FROM orders;

-- Example of AVG ignoring NULL

SELECT
    AVG(CAST(amount AS DECIMAL(10,2))) AS average_payment_amount,
    COUNT(*) AS total_payment_records,
    COUNT(amount) AS non_null_payment_amounts
FROM payments;
