create database ecommerce_analysis;
use ecommerce_analysis;

select * from order_details;



SET SQL_SAFE_UPDATES = 0;
SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_products
FROM products;

-- Total Revenue

SELECT 
    ROUND(SUM(p.price * od.quantity * (1 - od.discount)), 2) AS total_revenue
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid';
  
-- Total Profit

SELECT 
    ROUND(SUM(
        ((p.price * (1 - od.discount)) - p.cost) * od.quantity
    ), 2) AS total_profit
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND p.Cost_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid';
  
-- Average Order Value (AOV)

SELECT 
    ROUND(
        SUM(p.price * od.quantity * (1 - od.discount))
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid'; 
  
  -- Monthly Sales Trend
  
  SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(p.price * od.quantity * (1 - od.discount)),
            2) AS monthly_revenue
FROM
    order_details od
        JOIN
    orders o ON od.order_id = o.order_id
        JOIN
    products p ON od.product_id = p.product_id
WHERE
    o.order_status = 'Delivered'
        AND p.Price_Status = 'Valid'
        AND od.Quantity_Status = 'Valid'
        AND od.Discount_Status = 'Valid'
        AND o.order_date IS NOT NULL
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- Top 10 Products by Revenue

SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(p.price * od.quantity * (1 - od.discount)), 2) AS revenue
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- Category-wise Revenue

SELECT
    p.category,
    ROUND(SUM(p.price * od.quantity * (1 - od.discount)), 2) AS revenue
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid'
GROUP BY p.category
ORDER BY revenue DESC;

-- State-wise Revenue

SELECT
    c.state,
    ROUND(SUM(p.price * od.quantity * (1 - od.discount)), 2) AS revenue
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid'
GROUP BY c.state
ORDER BY revenue DESC;

-- Top Customers by Revenue

SELECT
    c.customer_id,
    c.customer_name,
    ROUND(
        SUM(p.price * od.quantity * (1 - od.discount)),
        2
    ) AS revenue
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 10;

-- Order Status Analysis.

SELECT
    COALESCE(NULLIF(TRIM(order_status), ''), 'Missing') AS order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY COALESCE(NULLIF(TRIM(order_status), ''), 'Missing')
ORDER BY total_orders DESC;

-- Cancellation Rate + Return Rate

SELECT
    ROUND(
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate,

    ROUND(
        SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS return_rate
FROM orders;

-- Payment Method Analysis

SELECT
    COALESCE(NULLIF(TRIM(payment_method), ''), 'Missing') AS payment_method,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY COALESCE(NULLIF(TRIM(payment_method), ''), 'Missing')
ORDER BY total_orders DESC;

-- Repeat Customer Analysis

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- Repeat Customer Rate  

SELECT
    COUNT(*) AS repeat_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customers),
        2
    ) AS repeat_customer_rate
FROM (
    SELECT customer_id
    FROM orders
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS repeat_data;

-- Category-wise Profit.

SELECT
    p.category,
    ROUND(
        SUM(
            ((p.price * (1 - od.discount)) - p.cost) * od.quantity
        ),
        2
    ) AS total_profit
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND p.Cost_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid'
GROUP BY p.category
ORDER BY total_profit DESC;

-- Profit Margin %

SELECT
    p.category,
    ROUND(
        SUM(((p.price * (1 - od.discount)) - p.cost) * od.quantity)
        /
        SUM(p.price * od.quantity * (1 - od.discount))
        * 100,
        2
    ) AS profit_margin_percentage
FROM order_details od
JOIN orders o
    ON od.order_id = o.order_id
JOIN products p
    ON od.product_id = p.product_id
WHERE o.order_status = 'Delivered'
  AND p.Price_Status = 'Valid'
  AND p.Cost_Status = 'Valid'
  AND od.Quantity_Status = 'Valid'
  AND od.Discount_Status = 'Valid'
GROUP BY p.category
ORDER BY profit_margin_percentage DESC;
