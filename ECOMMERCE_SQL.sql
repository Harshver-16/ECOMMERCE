-- 🧾 Create Transaction Dimension Table
CREATE TABLE Trans_dim (
    id SERIAL PRIMARY KEY,
    payment_key CHAR(10) UNIQUE,
    trans_type VARCHAR(50),
    bank_name VARCHAR(100)
);

-- 🏬 Create Store Dimension Table
CREATE TABLE store_dim (
    id SERIAL PRIMARY KEY,
    store_key CHAR(10) UNIQUE,
    division VARCHAR(50),
    district VARCHAR(50),
    upazila VARCHAR(50)
);

-- 🕒 Create Time Dimension Table
CREATE TABLE time_dim (
    id SERIAL PRIMARY KEY,
    time_key CHAR(20) UNIQUE,
    date DATE,
    hour TIME,
    day INT,
    week CHAR(20),
    month CHAR(20),
    quarter CHAR(20),
    year INT
);

-- 📦 Create Item Dimension Table
CREATE TABLE item_dim (
    id SERIAL PRIMARY KEY,
    item_key CHAR(20) UNIQUE,
    item_name VARCHAR(100),
    description TEXT,
    unit_price DECIMAL(10, 2),
    man_country VARCHAR(50),
    supplier VARCHAR(100),
    unit VARCHAR(20)
);

-- 👥 Create Customer Dimension Table
CREATE TABLE customer_dim (
    id SERIAL PRIMARY KEY,
    customer_key CHAR(20) UNIQUE,
    name VARCHAR(100),
    contact_no BIGINT,
    nid BIGINT
);

-- 📊 Create Fact Table
CREATE TABLE fact_table (
    id SERIAL PRIMARY KEY,
    payment_key CHAR(20),
    customer_key CHAR(20),
    time_key CHAR(20),
    item_key CHAR(20),
    store_key CHAR(20),
    quantity INT,
    unit VARCHAR(20),
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(12, 2)
);

SELECT * FROM trans_dim;
SELECT * FROM item_dim;
SELECT * FROM customer_dim;
SELECT * FROM fact_table;
SELECT * FROM time_dim;
SELECT * FROM store_dim;

--Top 10 Customers by Spending--
WITH cte AS (
    SELECT 
        customer_key,
        quantity,
        unit_price,
        quantity * unit_price AS total_value
    FROM fact_table
)
SELECT
    c.name AS customer_name,
    SUM(ct.total_value) AS total_spent
FROM cte ct
JOIN customer_dim c ON ct.customer_key = c.customer_key
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 10;

--Top 10 Items by Revenue--

WITH cte AS (
    SELECT 
        item_key,
        quantity,
        unit_price,
        quantity * unit_price AS total_value
    FROM fact_table
)
SELECT
    i.item_name,
    SUM(ct.total_value) AS total_revenue
FROM cte ct
JOIN item_dim i ON ct.item_key = i.item_key
GROUP BY i.item_name
ORDER BY total_revenue DESC
LIMIT 10;

--Monthly Sales (Any 5 Months)--

SELECT
    t.month,
    SUM(f.total_price) AS total_sales
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.month
ORDER BY t.month
LIMIT 5;

-- Top 5 Dates by Sales--
SELECT
    t.date,
    SUM(f.total_price) AS total_sales
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.date
ORDER BY total_sales DESC
LIMIT 5;

--TOP 5 MONTHS--
SELECT
    t.month,
    SUM(f.total_price) AS total_sales
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.month
ORDER BY total_sales DESC
LIMIT 5;

--TOP 5 DAY--
SELECT
    t.day,
    SUM(f.total_price) AS total_sales
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.day
ORDER BY total_sales DESC
LIMIT 5;

--Revenue by Manufacturer Country--

SELECT
    i.man_country,
    SUM(f.total_price) AS total_revenue
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
GROUP BY i.man_country
ORDER BY total_revenue DESC;

--Units Sold by Type--

SELECT
    f.unit,
    COUNT(*) AS transaction_count,
    SUM(f.quantity) AS total_units_sold
FROM fact_table f
GROUP BY f.unit
ORDER BY total_units_sold DESC;

--Top 10 Customers by Number of Transactions--

SELECT 
    customer_key,
    COUNT(*) AS transaction_count
FROM fact_table
GROUP BY customer_key
ORDER BY transaction_count DESC
LIMIT 10;


--Top 10 Payment Types by Revenue--

SELECT 
    td.trans_type,
    SUM(ft.quantity * ft.unit_price) AS total_value
FROM fact_table ft
JOIN trans_dim td ON ft.payment_key = td.payment_key
GROUP BY td.trans_type
ORDER BY total_value DESC
LIMIT 10;


-- Top 10 Banks by Total Spent--

WITH cte AS (
    SELECT 
        customer_key,
        payment_key,
        quantity,
        unit_price,
        quantity * unit_price AS total_value
    FROM fact_table
)
SELECT 
    td.bank_name,
    SUM(ct.total_value) AS total_spent
FROM cte ct
JOIN trans_dim td ON ct.payment_key = td.payment_key
WHERE td.bank_name IS NOT NULL
GROUP BY td.bank_name
ORDER BY total_spent DESC
LIMIT 10;



-- Top 10 Bank + Payment Method Combinations by Spending--

WITH cte AS (
    SELECT 
        customer_key,
        payment_key,
        quantity,
        unit_price,
        quantity * unit_price AS total_value
    FROM fact_table
)
SELECT 
    td.bank_name,
    td.trans_type AS payment_method,
    SUM(ct.total_value) AS total_spent
FROM cte ct
JOIN trans_dim td ON ct.payment_key = td.payment_key
WHERE td.bank_name IS NOT NULL
GROUP BY td.bank_name, td.trans_type
ORDER BY total_spent DESC
LIMIT 10;

--Top 5 Years by Revenue--

SELECT 
    t.year,
    SUM(f.quantity * f.unit_price) AS total_revenue
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.year
ORDER BY total_revenue DESC
LIMIT 5;
