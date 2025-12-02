-- =======================================
-- transformations.sql
-- Build dimensions and fact table
-- from raw_pharmacy_sales
-- =======================================

-- 0) ASSUMPTION:
-- The CSV from Kaggle has been loaded into the table raw_pharmacy_sales
-- (defined in create_tables.sql).
-- Columns: date, country, region, product, category, quantity, unit_price, total_sales

-------------------------------------------------
-- 1. dim_product
-------------------------------------------------
-- One row per unique product + category
DELETE FROM dim_product;

INSERT INTO dim_product (product_id, product_name, category)
SELECT
    ROW_NUMBER() OVER (ORDER BY product, category) AS product_id,
    product     AS product_name,
    category
FROM (
    SELECT DISTINCT
        product,
        category
    FROM raw_pharmacy_sales
) t;

-------------------------------------------------
-- 2. dim_country
-------------------------------------------------
-- One row per unique country + region
DELETE FROM dim_country;

INSERT INTO dim_country (country_code, country_name, region)
SELECT
    UPPER(SUBSTR(country, 1, 2)) AS country_code,  -- e.g. "United Kingdom" -> "UN"
    country                      AS country_name,
    region
FROM (
    SELECT DISTINCT
        country,
        region
    FROM raw_pharmacy_sales
) t;

-------------------------------------------------
-- 3. fact_sales
-------------------------------------------------
-- Main clean fact table for analysis
DELETE FROM fact_sales;

INSERT INTO fact_sales (
    sale_id,
    order_date,
    date_key,
    country_code,
    product_id,
    quantity,
    unit_price,
    revenue
)
SELECT
    ROW_NUMBER() OVER (ORDER BY r.date, r.country, r.product) AS sale_id,
    r.date          AS order_date,
    r.date          AS date_key,                 -- will join to dim_date.date
    UPPER(SUBSTR(r.country, 1, 2)) AS country_code,
    p.product_id,
    r.quantity,
    r.unit_price,
    COALESCE(r.total_sales, r.quantity * r.unit_price) AS revenue
FROM raw_pharmacy_sales r
JOIN dim_product p
  ON r.product = p.product_name;

-------------------------------------------------
-- 4. dim_date
-------------------------------------------------
-- Build a date dimension based on the dates we see in the data.
-- NOTE: date functions (strftime) below are SQLite-style.
-- In other databases, you'll need to adjust the syntax.

DELETE FROM dim_date;

INSERT INTO dim_date (date, year, quarter, month, month_name, week)
SELECT
    d AS date,
    CAST(STRFTIME('%Y', d) AS INTEGER)                         AS year,
    ((CAST(STRFTIME('%m', d) AS INTEGER) - 1) / 3) + 1         AS quarter,
    CAST(STRFTIME('%m', d) AS INTEGER)                         AS month,
    STRFTIME('%m', d)                                          AS month_name, -- you can map to names later
    CAST(STRFTIME('%W', d) AS INTEGER)                         AS week
FROM (
    SELECT DISTINCT
        order_date AS d
    FROM fact_sales
) x
ORDER BY d;
