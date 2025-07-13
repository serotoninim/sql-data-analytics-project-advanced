 -- Part to Whole
 /*Bir parçanın genel performansla karşılaştırıldığında nasıl performans gösterdiğini analiz ederek,
hangi kategorinin işletme üzerinde en büyük etkiye sahip olduğunu anlamamızı sağlar*/

-- Hangi kategoriler genel satışlara en çok katkıda bulunuyor?
WITH category_sales AS(
SELECT
category,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY category)

SELECT
category,
total_sales,
--SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((total_sales / SUM(total_sales) OVER ())*100,2),'%') AS percentaghe_of_total
FROM category_sales
ORDER BY total_sales DESC


-- subcategory_sales Part to Whole

WITH subcategory_sales AS(
SELECT
subcategory,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY subcategory)

SELECT
subcategory,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((total_sales / SUM(total_sales) OVER ())*100,2),'%') AS percentaghe_of_total
FROM subcategory_sales
ORDER BY total_sales DESC