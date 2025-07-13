-- Cumulative Analysis: Zaman içinde biriken toplam değeri gösterir.
--Month
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
date_trunc('month', order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY date_trunc('month', order_date)
ORDER BY order_date) t
--Year
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
ROUND(AVG(avg_price) OVER (ORDER BY order_date),1) AS moving_average_price
FROM
(
SELECT
date_trunc('year', order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY date_trunc('year', order_date)
ORDER BY order_date) t