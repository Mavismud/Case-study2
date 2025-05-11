SELECT
  *
FROM
  "BRIGHT_COFFE"."PUBLIC"."SHOP"
LIMIT
  10;
  
---Adding column

ALTER TABLE "BRIGHT_COFFE"."PUBLIC"."SHOP"
ADD COLUMN transaction_datetime TIMESTAMP;

ALTER TABLE "BRIGHT_COFFE"."PUBLIC"."SHOP"
ADD COLUMN total_amount FLOAT;

ALTER TABLE "BRIGHT_COFFE"."PUBLIC"."SHOP"
ADD COLUMN transaction_time_bucket STRING;

-- Populate combined timestamp

UPDATE "BRIGHT_COFFE"."PUBLIC"."SHOP"
SET transaction_datetime = TO_TIMESTAMP_NTZ(
  CAST(transaction_date AS STRING) || ' ' || CAST(transaction_time AS STRING),
  'YYYY/MM/DD HH24:MI:SS'
)
WHERE transaction_date IS NOT NULL AND transaction_time IS NOT NULL;


--Compute total amount
UPDATE "BRIGHT_COFFE"."PUBLIC"."SHOP"
SET total_amount = unit_price * transaction_qty;

ALTER TABLE "BRIGHT_COFFE"."PUBLIC"."SHOP"
ADD COLUMN IF NOT EXISTS total_amount FLOAT;

SELECT 
  unit_price, 
  transaction_qty,
  TRY_CAST(unit_price AS FLOAT) * TRY_CAST(transaction_qty AS INT) AS calc_amount
FROM "BRIGHT_COFFE"."PUBLIC"."SHOP"
LIMIT 10;

UPDATE "BRIGHT_COFFE"."PUBLIC"."SHOP"
SET total_amount = unit_price * transaction_qty
WHERE unit_price IS NOT NULL AND transaction_qty IS NOT NULL;
ALTER TABLE "BRIGHT_COFFE"."PUBLIC"."SHOP"
ALTER COLUMN unit_price SET DATA TYPE FLOAT;

UPDATE "BRIGHT_COFFE"."PUBLIC"."SHOP"
SET unit_price = REPLACE(unit_price, ',', '.')
WHERE unit_price LIKE '%,%';


ALTER TABLE "BRIGHT_COFFE"."PUBLIC"."SHOP"
ADD COLUMN unit_price_clean FLOAT;

UPDATE "BRIGHT_COFFE"."PUBLIC"."SHOP"
SET unit_price_clean = TRY_TO_DOUBLE(REPLACE(unit_price, ',', '.'))
WHERE unit_price IS NOT NULL;

ALTER TABLE "BRIGHT_COFFE"."PUBLIC"."SHOP"
ADD COLUMN IF NOT EXISTS total_amount FLOAT;

UPDATE "BRIGHT_COFFE"."PUBLIC"."SHOP"
SET total_amount = unit_price_clean * transaction_qty
WHERE unit_price_clean IS NOT NULL AND transaction_qty IS NOT NULL;

--Create time bucket (rounded to nearest hour)
UPDATE "BRIGHT_COFFE"."PUBLIC"."SHOP"
SET transaction_time_bucket = TO_CHAR(DATE_TRUNC('HOUR', transaction_datetime), 'HH24:MI');

 -- Revenue by product category
SELECT product_category, SUM(total_amount) AS revenue
FROM "BRIGHT_COFFE"."PUBLIC"."SHOP"
GROUP BY product_category
ORDER BY revenue DESC;

-- Quantity by time bucket
SELECT transaction_time_bucket, SUM(transaction_qty) AS total_sold
FROM "BRIGHT_COFFE"."PUBLIC"."SHOP"
GROUP BY transaction_time_bucket
ORDER BY transaction_time_bucket;

-- Best-selling product details
SELECT product_detail, SUM(total_amount) AS total_revenue
FROM"BRIGHT_COFFE"."PUBLIC"."SHOP"
GROUP BY product_detail
ORDER BY total_revenue DESC
LIMIT 10;

