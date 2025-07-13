-- Change Over Time Trends: Belirli aralıklarla (ay, yıl vb.),
-- değerlerin nasıl değiştiğini ve trendini ortaya koyar.
SELECT
	date_trunc('month', order_date) as order_date,
    SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY date_trunc('month', order_date)
ORDER BY order_date;




