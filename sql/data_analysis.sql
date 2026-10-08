-- =========================================================
-- E-Commerce Sales & Customer Analytics
-- SQL Business Analysis
-- =========================================================


-- =========================================================
-- 1. Overall Business KPIs
-- =========================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(oi.revenue) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    ROUND(
        SUM(oi.profit) / NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- =========================================================
-- 2. Average Order Value
-- =========================================================

SELECT
    ROUND(
        SUM(oi.revenue) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- =========================================================
-- 3. Monthly Revenue
-- =========================================================

SELECT
    DATE_TRUNC('month', o.order_date)::date AS month,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY 1;


-- =========================================================
-- 4. Revenue by Product Category
-- =========================================================

SELECT
    p.category,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit,
    SUM(oi.quantity) AS quantity_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;


-- =========================================================
-- 5. Top 10 Products by Revenue
-- =========================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 6. Top 10 Products by Profit
-- =========================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    ROUND(SUM(oi.profit), 2) AS profit,
    ROUND(SUM(oi.revenue), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY profit DESC
LIMIT 10;


-- =========================================================
-- 7. Revenue by State
-- =========================================================

SELECT
    c.state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.state
ORDER BY revenue DESC;


-- =========================================================
-- 8. Order Status Analysis
-- =========================================================

SELECT
    o.status,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.revenue), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.status
ORDER BY orders DESC;


-- =========================================================
-- 9. Cancellation Rate
-- =========================================================

SELECT
    ROUND(
        COUNT(*) FILTER (WHERE status = 'Cancelled') * 100.0
        / COUNT(*),
        2
    ) AS cancellation_rate
FROM orders;


-- =========================================================
-- 10. Return Rate
-- =========================================================

SELECT
    ROUND(
        COUNT(*) FILTER (WHERE status = 'Returned') * 100.0
        / COUNT(*),
        2
    ) AS return_rate
FROM orders;


-- =========================================================
-- 11. Payment Method Analysis
-- =========================================================

SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY payment_method
ORDER BY revenue DESC;


-- =========================================================
-- 12. Delivery Performance
-- =========================================================

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(shipping_days), 2) AS avg_shipping_days,
    MIN(shipping_days) AS fastest_delivery,
    MAX(shipping_days) AS slowest_delivery
FROM orders
WHERE status = 'Delivered';


-- =========================================================
-- 13. Top 10 Customers by Revenue
-- =========================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.revenue), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city,
    c.state
ORDER BY total_revenue DESC
LIMIT 10;

-- =========================================================
-- 14. One-Time vs Repeat Customers
-- =========================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type
ORDER BY customer_count DESC;


-- =========================================================
-- 15. Top Customers by Purchase Frequency
-- =========================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.revenue), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_orders DESC
LIMIT 10;


-- =========================================================
-- 16. Customer Lifetime Value
-- =========================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.revenue), 2) AS lifetime_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY lifetime_value DESC
LIMIT 10;


-- =========================================================
-- 17. Discount Impact on Revenue and Profit
-- =========================================================

SELECT
    oi.discount_percent,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit,
    ROUND(
        SUM(oi.profit) /
        NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin
FROM order_items oi
GROUP BY oi.discount_percent
ORDER BY oi.discount_percent;


-- =========================================================
-- 18. Category Profit Margin
-- =========================================================

SELECT
    p.category,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit,
    ROUND(
        SUM(oi.profit) /
        NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY profit_margin DESC;


-- =========================================================
-- 19. Monthly Order Volume
-- =========================================================

SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY 1
ORDER BY 1;


-- =========================================================
-- 20. Monthly Average Order Value
-- =========================================================

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.revenue) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT
    month,
    orders,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue / NULLIF(orders, 0), 2) AS average_order_value
FROM monthly_sales
ORDER BY month;


-- =========================================================
-- 21. Revenue by Customer Gender
-- =========================================================

SELECT
    c.gender,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.gender
ORDER BY revenue DESC;


-- =========================================================
-- 22. Revenue by Age Group
-- =========================================================

SELECT
    CASE
        WHEN c.age < 25 THEN '18-24'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY age_group
ORDER BY revenue DESC;


-- =========================================================
-- 23. Top Subcategories by Revenue
-- =========================================================

SELECT
    p.category,
    p.subcategory,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.category,
    p.subcategory
ORDER BY revenue DESC
LIMIT 15;


-- =========================================================
-- 24. Products with High Sales but Low Profit Margin
-- =========================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS quantity_sold,
    ROUND(SUM(oi.revenue), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit,
    ROUND(
        SUM(oi.profit) /
        NULLIF(SUM(oi.revenue), 0) * 100,
        2
    ) AS profit_margin
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
HAVING SUM(oi.quantity) >= 20
ORDER BY profit_margin ASC
LIMIT 10;
