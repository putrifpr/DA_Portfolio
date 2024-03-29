USE pizza;
SELECT * FROM pizza_sales;

DESCRIBE pizza_sales;

ALTER TABLE pizza_sales
MODIFY order_date DATETIME;

ALTER TABLE pizza_sales
MODIFY order_time TIME;

-- ANALIS DATA --

-- 1. Total Revenue
SELECT
	sum(total_price) AS total_revenue
FROM pizza_sales;

-- 2. Rata-rata nominal pembelian
SELECT
	sum(total_price) / count(DISTINCT order_id) AS avg_price_order
FROM pizza_sales;

-- 3. Total pizza terjual
SELECT
	sum(quantity) AS total_pizza_sold
FROM pizza_sales;

-- 4. Total order keseluruhan
SELECT
	count(DISTINCT order_id) AS total_order
FROM pizza_sales;

-- 5. Rata-rata jumlah pembelian pizza
SELECT
	sum(quantity) / count(DISTINCT order_id)
FROM pizza_sales;

-- 6. Total order masing-masing hari
SELECT
	DAYNAME(order_date) AS order_day,
    COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY DAYNAME(order_date)
ORDER BY total_orders DESC;

-- 7. Total order masing-masing bulan
SELECT
	MONTHNAME(order_date) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY MONTHNAME(order_date)
ORDER BY total_orders DESC;

-- 8. Persentase penjualan berdasarkan kategori pizza
SELECT
	pizza_category,
    ROUND(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sales), 3) as percentage_sales
FROM pizza_sales
GROUP BY pizza_category;

-- 9. Total penjualan dan persentase berdasarkan ukuran pizza (range waktu = quarter)
SELECT
	pizza_size,
	ROUND(SUM(total_price), 3) AS total_sales,
    ROUND(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sales), 3) as percentage_sale
FROM pizza_sales
WHERE QUARTER(order_date) BETWEEN 1 AND 2
GROUP BY pizza_size
ORDER BY percentage_sale DESC;

-- 10. Top 5 pizza dengan pendapatan terbesar
SELECT
	pizza_name,
	SUM(total_price) AS total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 11. Top 5 pizza dengan pendapatan terendah
SELECT
	pizza_name,
	SUM(total_price) AS total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_revenue ASC
LIMIT 5;

-- 12.