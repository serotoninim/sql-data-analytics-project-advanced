 /*
===============================================================================
Ürün Raporu
===============================================================================
Amaç
- Bu rapor, temel ürün metriklerini ve davranışlarını bir araya getirir.

Önemli Noktalar:
1. Ürün adı, kategori, alt kategori ve maliyet gibi temel alanları bir araya getirir.
2. Yüksek Performans Gösterenleri, Orta Seviyede Performans Gösterenleri veya Düşük Performans Gösterenleri belirlemek için ürünleri gelirlerine göre segmentlere ayırır.
3. Ürün düzeyinde metrikleri toplar:
- toplam si̇pari̇şler
- toplam satış
- satılan toplam miktar
- toplam müşteri (tekil)
- yaşam süresi (ay olarak)
===============================================================================
*/
-- =============================================================================
CREATE VIEW gold.report_products AS

WITH base_query AS (
SELECT
		f.order_number,
        f.order_date,
		f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
FROM gold.fact_sales as f
LEFT JOIN gold.dim_products as p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL)
,

product_aggregations AS (
SELECT
	product_key,
    product_name,
    category,
    subcategory,
	MIN(order_date) AS last_sales_date,
    cost,
	SUM(sales_amount) as total_sales,
	SUM(quantity) as total_quantity,
	DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12 +
	DATE_PART('month',AGE(MAX(order_date),MIN(order_date))) AS lifespand,
	COUNT(DISTINCT(customer_key)) AS total_customer,
	COUNT(DISTINCT(order_number)) AS total_orders
FROM base_query
GROUP BY product_key,
product_name,
category,
subcategory,
cost)

SELECT
  product_key,
  product_name,
  category,
  subcategory,
  cost,
  last_sales_date,
  DATE_PART('year', AGE(CURRENT_DATE, last_sales_date)) * 12 +
  DATE_PART('month', AGE(CURRENT_DATE, last_sales_date)) AS recency,
  CASE
    WHEN total_sales > 50000 THEN 'High Performance'
    WHEN total_sales < 10000 THEN 'Low Performers'
    ELSE 'Mid-Range'
  END AS product_segment,
  lifespand,
  total_orders,
  total_sales,
  total_quantity,
  total_customer
FROM product_aggregations 

