/* Ürünlerin yıllık performansını, satışlarını hem ürünün ortalama 
satış performansıyla hem de bir önceki yılın satışlarıyla karşılaştırarak analiz edin.*/

-- Year-over-year Analysis
WITH yearly_product_sales AS (
SELECT
EXTRACT(YEAR FROM f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM f.order_date),
p.product_name
ORDER BY product_name, order_year
)

SELECT
order_year,
product_name,
current_sales,
ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) AS avg_sales,
current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) AS diff_avg,
CASE WHEN current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) > 0 THEN 'Above Avg'
	 WHEN current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - ROUND(LAG(current_sales)OVER (PARTITION BY product_name),0) > 0 THEN 'Increase'
	WHEN current_sales - ROUND(LAG(current_sales)OVER (PARTITION BY product_name),0) < 0 THEN 'Decrease'
	ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year
