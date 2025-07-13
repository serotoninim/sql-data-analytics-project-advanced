/*Amaç:
- Bu rapor, temel müşteri ölçümlerini ve davranışlarını konsolide eder
Önemli Noktalar:
1. Adlar, yaşlar ve işlem ayrıntıları gibi temel alanları bir araya getirir.
2. Müşterileri kategorilere (VIP, Düzenli, Yeni) ve yaş gruplarına ayırır.
3. Müşteri düzeyinde metrikleri toplar:
- toplam si̇pari̇şler
- toplam satış
- satın alınan toplam miktar
- toplam ürünler
- yaşam süresi (ay olarak)
4. Değerli KPI'ları hesaplar:
- gecikme (son siparişten bu yana geçen aylar)
- ortalama sipariş değeri
- ortalama aylık harcama
*/
-- (1kez çalıştırın ) CREATE VIEW gold.report_customers AS
WITH base_quary AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
DATE_PART('year', AGE(c.birthdate)) as age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS(
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) as total_order,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12 +
	DATE_PART('month', AGE(MAX(order_date), MIN(order_date))) AS lifespan
FROM base_quary
GROUP BY customer_key,
customer_number,
customer_name,
age
)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		WHEN age < 20 THEN 'Under 20'
		 WHEN age between 20 and 29 THEN '20-29'
		 WHEN age between 30 and 39 THEN '30-39'
		 WHEN age between 40 and 49 THEN '40-49'
		 ELSE '50 and above'
	END AS age_segment,
	CASE
		WHEN lifespan >= 12 AND total_sales >= 5000 THEN 'VIP'
		WHEN lifespan >= 12  AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New Customer'
	END AS customer_segment,
	last_order_date,
	DATE_PART('year', AGE(CURRENT_DATE, last_order_date)) * 12 +
	DATE_PART('month', AGE(CURRENT_DATE, last_order_date)) AS recency,
	total_order,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compuate average order value (AVO)
	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales / total_order
	END AS avg_order_value,
	-- Compuate average monthly spend
	CASE WHEN lifespan = 0 THEN total_sales
	     ELSE total_sales / lifespan
	END AS avg_monthly_spend
	FROM customer_aggregation
	