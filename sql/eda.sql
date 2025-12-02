-- =======================================
-- eda.sql
-- Exploratory data analysis queries
-- =======================================

-----------------------------------------
-- 1. Monthly revenue trend
-----------------------------------------
SELECT
    DATE(order_date, 'start of month') AS month_start,
    SUM(revenue) AS total_revenue
FROM fact_sales
GROUP BY DATE(order_date, 'start of month')
ORDER BY month_start;

-----------------------------------------
-- 2. Revenue by product category
-----------------------------------------
SELECT
    p.category,
    SUM(f.revenue) AS revenue,
    SUM(f.quantity) AS units,
    AVG(f.unit_price) AS avg_unit_price
FROM fact_sales f
JOIN dim_product p
  ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-----------------------------------------
-- 3. Top 10 products by revenue
-----------------------------------------
SELECT
    p.product_name,
    p.category,
    SUM(f.revenue) AS revenue,
    SUM(f.quantity) AS units
FROM fact_sales f
JOIN dim_product p
  ON f.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-----------------------------------------
-- 4. Revenue by region and country
-----------------------------------------
SELECT
    c.region,
    c.country_name,
    SUM(f.revenue) AS revenue,
    SUM(f.quantity) AS units
FROM fact_sales f
JOIN dim_country c
  ON f.country_code = c.country_code
GROUP BY c.region, c.country_name
ORDER BY revenue DESC;

-----------------------------------------
-- 5. Average selling price by country
-----------------------------------------
SELECT
    c.country_name,
    SUM(f.revenue) / NULLIF(SUM(f.quantity), 0) AS avg_selling_price
FROM fact_sales f
JOIN dim_country c
  ON f.country_code = c.country_code
GROUP BY c.country_name
ORDER BY avg_selling_price DESC;
