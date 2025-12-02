-- ============================
-- 1. Staging table for raw Kaggle data
-- ============================
-- This matches the columns in the CSV file from Kaggle.
-- You will load the CSV into this table.
CREATE TABLE raw_pharmacy_sales (
    date        DATE,
    country     TEXT,
    region      TEXT,
    product     TEXT,
    category    TEXT,
    quantity    INTEGER,
    unit_price  REAL,
    total_sales REAL
);

-- ============================
-- 2. Dimension tables
-- ============================

-- Unique list of products and their category
CREATE TABLE dim_product (
    product_id    INTEGER PRIMARY KEY,
    product_name  TEXT,
    category      TEXT
);

-- Unique list of countries and regions
CREATE TABLE dim_country (
    country_code   TEXT PRIMARY KEY,
    country_name   TEXT,
    region         TEXT
);

-- Date dimension for reporting (year, month, etc.)
CREATE TABLE dim_date (
    date        DATE PRIMARY KEY,
    year        INTEGER,
    quarter     INTEGER,
    month       INTEGER,
    month_name  TEXT,
    week        INTEGER
);

-- ============================
-- 3. Fact table (clean sales)
-- ============================
-- This is the main table used for analysis & dashboards.
CREATE TABLE fact_sales (
    sale_id       INTEGER PRIMARY KEY,
    order_date    DATE,
    date_key      DATE,          -- joins to dim_date.date
    country_code  TEXT,          -- joins to dim_country.country_code
    product_id    INTEGER,       -- joins to dim_product.product_id
    quantity      INTEGER,
    unit_price    REAL,
    revenue       REAL
);
