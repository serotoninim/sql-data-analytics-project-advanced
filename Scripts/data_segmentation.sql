-- Data Segmentation

/*WITH products_segment AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold.dim_products)

SELECT
cost_range,
COUNT(product_key) AS total_product
FROM products_segment
GROUP BY cost_range
ORDER BY total_product DESC 
*/


/*Müşterileri harcama davranışlarına göre üç segmentte gruplandırın:
- VIP: En az 12 aylık geçmişi olan ve €5,0@@'dan fazla harcama yapan müşteriler.
- Düzenli müşteriler: En az 12 aylık geçmişi olan ancak 5.000 € veya daha az harcama yapan müşteriler.
- Yeni müşteriler: Yaşam süresi 12 aydan az olan müşteriler.

 Ve her bir grubun toplam müşteri sayısını bulun
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATE_PART('year', AGE(MAX(f.order_date), MIN(f.order_date))) * 12 +
        DATE_PART('month', AGE(MAX(f.order_date), MIN(f.order_date))) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;










