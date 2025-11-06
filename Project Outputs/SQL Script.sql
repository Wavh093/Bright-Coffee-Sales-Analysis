SELECT * FROM bcoffee.sales.transactions;

-- just viewing all locations
SELECT STORE_LOCATION FROM bcoffee.sales.transactions;

-- the time the store opens
SELECT MIN(transaction_time) 
FROM bcoffee.sales.transactions;

-- the time the store closes
SELECT MAX(transaction_time) 
FROM bcoffee.sales.transactions;

-- total revenue per store
SELECT DISTINCT Store_location, 
SUM(unit_price * transaction_qty)  OVER (PARTITION BY store_location) AS Tot_revenue
FROM bcoffee.sales.transactions;

-- total revenue per category
SELECT DISTINCT product_category, 
SUM(unit_price * transaction_qty)  OVER (PARTITION BY product_category) AS Tot_revenue
FROM bcoffee.sales.transactions
ORDER BY tot_revenue DESC;

-- Total revenue per product type
SELECT DISTINCT product_type, 
SUM(unit_price * transaction_qty)  OVER (PARTITION BY product_type) AS Tot_revenue
FROM bcoffee.sales.transactions
ORDER BY tot_revenue DESC;

-- adding the total revenue per column
ALTER TABLE bcoffee.sales.transactions
ADD tot_revenue DECIMAL(10,2);

UPDATE bcoffee.sales.transactions
SET tot_revenue = unit_price * transaction_qty;

SELECT MONTHNAME(transaction_date)
FROM bcoffee.sales.transactions;

-- add the month name column
ALTER TABLE bcoffee.sales.transactions
ADD month_name VARCHAR(20);

UPDATE bcoffee.sales.transactions
SET month_name = MONTHNAME(transaction_date);
-- total per month, per category
SELECT product_category,MONTHNAME(transaction_date) AS month_of_transaction, 
SUM(tot_revenue) AS product_category_revenue
FROM bcoffee.sales.transactions
GROUP BY product_category, month_of_transaction
ORDER BY month_of_transaction ASC;

-- total per month, per store
SELECT store_location,MONTHNAME(transaction_date) AS month_of_transaction, 
SUM(tot_revenue) AS store_location_revenue
FROM bcoffee.sales.transactions
GROUP BY store_location, month_of_transaction;

-- Revenue by hour
SELECT HOUR(transaction_time)  AS transaction_hour,
SUM(tot_revenue) AS per_hour_revenue
FROM bcoffee.sales.transactions
GROUP BY transaction_hour
ORDER BY transaction_hour ASC;

-- revenue by day of week
SELECT DAYOFWEEK(transaction_date) AS day_of_week,
DAYNAME(transaction_date) AS transaction_day,
SUM(tot_revenue) AS per_day_revenue
FROM bcoffee.sales.transactions
GROUP BY transaction_day, day_of_week
ORDER BY day_of_week;

-- revenue over time
SELECT 
    transaction_date,
    SUM(unit_price * transaction_qty) AS total_revenue
FROM bcoffee.sales.transactions
GROUP BY transaction_date
ORDER BY transaction_date;

-- Average customer value
SELECT
    SUM(tot_revenue)/ COUNT(DISTINCT transaction_id) AS average_revenue_per_transaction
    FROM bcoffee.sales.transactions;

-- Add a time bucket column
ALTER TABLE bcoffee.sales.transactions
ADD COLUMN transaction_time_bucket STRING;

UPDATE bcoffee.sales.transactions
    SET transaction_time_bucket =
         LPAD(DATE_PART('hour', transaction_time)::STRING, 2, '0') ||
    CASE 
        WHEN DATE_PART('minute', transaction_time) < 30 THEN 'h00'
        ELSE 'h30'
    END;

SELECT DAYNAME (transaction_date) AS day_name,
    CASE 
        WHEN day_name IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_classification,
    MONTHNAME(transaction_date) AS month_name,
    CASE
        WHEN transaction_time BETWEEN '06:00:00' AND '11:59:00' THEN 'Morning'
        WHEN transaction_time BETWEEN '12:00:00' AND '16:59:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS transaction_time,
    HOUR (transaction_time) AS hour_of_day,
    store_location,
    product_category,
    product_detail,
    COUNT(DISTINCT transaction_id) AS Num_of_sales,
    SUM(unit_price * transaction_qty) AS revenue
    FROM bcoffee.sales.transactions
    GROUP BY ALL;

    -- add them as columns
ALTER TABLE bcoffee.sales.transactions
ADD COLUMN section_of_week STRING;

UPDATE bcoffee.sales.transactions
    SET
        section_of_week =
        CASE
            WHEN DAYNAME(transaction_date) IN ('Sat', 'Sun') THEN 'Weekend'
            ELSE 'Weekday'
        END;

-- Adding the time of day
ALTER TABLE bcoffee.sales.transactions
ADD COLUMN time_of_day STRING;

UPDATE bcoffee.sales.transactions
    SET time_of_day = 
        CASE WHEN transaction_time BETWEEN '06:00:00' AND '11:59:00' THEN 'Morning'
        WHEN transaction_time BETWEEN '12:00:00' AND '16:59:00' THEN 'Afternoon'
        ELSE 'Evening'
    END;

-- day name column
ALTER TABLE bcoffee.sales.transactions
ADD COLUMN name_of_day STRING;

UPDATE bcoffee.sales.transactions
    SET name_of_day = DAYNAME(transaction_date);
