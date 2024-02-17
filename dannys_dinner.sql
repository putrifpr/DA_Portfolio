CREATE DATABASE dannys_dinner;

USE dannys_dinner;

CREATE TABLE sales(
	customer_id VARCHAR(2),
    order_date DATE,
    product_id INT
);

INSERT INTO sales
	(customer_id, order_date, product_id)
VALUES
	('A', '2021-01-01', 1),
    ('A', '2021-01-01', 2),
    ('A', '2021-01-07', 2),
    ('A', '2021-01-10', 3),
    ('A', '2021-01-11', 3),
    ('A', '2021-01-11', 3),
    ('B', '2021-01-01', 2),
    ('B', '2021-01-02', 2),
    ('B', '2021-01-04', 1),
    ('B', '2021-01-11', 1),
    ('B', '2021-01-16', 3),
    ('B', '2021-02-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-01', 3),
    ('A', '2021-01-07', 3);
    
UPDATE sales
SET customer_id = 'C'
WHERE order_date = '2021-01-07' AND product_id = 3;
    
CREATE TABLE menu(
	product_id INT,
    product_name VARCHAR(10),
    price INT
);

INSERT INTO menu
	(product_id, product_name, price)
VALUES
	(1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);
    
CREATE TABLE members(
	customer_id VARCHAR(2),
    join_date DATE
);

INSERT INTO members
	(customer_id, join_date)
VALUES
	('A', '2021-01-07'),
    ('B', '2021-01-09');
    
-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	customer_id,
    SUM(m.price) AS total_amount
FROM sales s
JOIN menu m USING (product_id)
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
    COUNT(DISTINCT order_date) AS total_visit
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH first_purchased AS (SELECT
	customer_id,
    MIN(order_date) AS first_date_visit
FROM sales
GROUP BY customer_id)
SELECT DISTINCT
	fp.customer_id,
    fp.first_date_visit,
    m.product_name
FROM first_purchased fp
JOIN sales s ON fp.customer_id = s.customer_id
JOIN menu m ON s.product_id = m.product_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customer?
SELECT
	m.product_name,
    COUNT(s.product_id) AS total_order
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_order DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
SELECT
	s.customer_id,
    m.product_name,
    COUNT(s.product_id) AS purchase_count,
	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank_food
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name;

-- Menampilkan Rank-1 Produk yang sering dibeli customer
WITH customer_popularity AS (
		SELECT
			s.customer_id AS id,
			m.product_name AS product,
			COUNT(s.product_id) AS purchase_count,
			ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank_food
		FROM sales s
		JOIN menu m ON s.product_id = m.product_id
		GROUP BY s.customer_id, m.product_name )
SELECT
	id,
	product,
	purchase_count
FROM customer_popularity
WHERE rank_food = 1;

-- 7. Which item was purchased first by the customer after they became a member?
WITH first_order_member AS (
		SELECT
			s.customer_id AS id,
			MIN(s.order_date) AS first_order_date
		FROM sales s
		JOIN members m USING (customer_id)
		WHERE s.order_date >= m.join_date
		GROUP BY s.customer_id )
SELECT
	id,
    mn.product_name
FROM first_order_member fom
JOIN sales s ON fom.id = s.customer_id AND fom.first_order_date = s.order_date
JOIN menu mn ON s.product_id = mn.product_id;

-- 8. Which item was purchases just before the customer became a member?
SELECT DISTINCT
    mn.product_name
FROM sales s
JOIN members m USING (customer_id)
JOIN menu mn ON s.product_id = mn.product_id
WHERE s.order_date < m.join_date;

-- 9. What is the total items and amount spent for each member before they became members?
SELECT
	s.customer_id,
    COUNT(s.product_id) AS qty_buy,
    SUM(price) AS total_buy
FROM sales s
JOIN members m USING (customer_id)
JOIN menu mn ON s.product_id = mn.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

-- 10. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	s.customer_id,
    SUM( CASE
		WHEN m.product_name = 'sushi' THEN m.price*20
        ELSE m.price*10
        END) AS points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 11. In the first week after a customer joins the program (including their join date) they earn 2x points on all items (not just sushi),
-- how many points do customer A and B has at the end of January?
SELECT
	s.customer_id,
    SUM(
		CASE
			WHEN s.order_date BETWEEN join_date AND DATE_ADD(m.join_date, INTERVAL 7 DAY)
				THEN mn.price*20
			WHEN mn.product_name = 'sushi' THEN mn.price*20
            ELSE mn.price*10 END) AS total_points
FROM sales s
LEFT JOIN members m ON s.customer_id = m.customer_id
JOIN menu mn ON s.product_id = mn.product_id
WHERE s.customer_id IN ('A', 'B') AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id;

-- Jumlah pendapatan perbulan
SELECT
	DATE_FORMAT(s.order_date, '%Y-%m') AS bulan,
    SUM(price) AS revenue
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY DATE_FORMAT(s.order_date, '%Y-%m');

-- Menu yang paling banyak dipesan tiap bulan
SELECT
	bulan,
    product_name
FROM (
		SELECT
			DATE_FORMAT(s.order_date, '%Y-%m') AS bulan,
			m.product_name,
			COUNT(s.product_id) AS total_order,
			ROW_NUMBER() OVER(PARTITION BY DATE_FORMAT(s.order_date, '%Y-%m') ORDER BY COUNT(s.product_id) DESC) AS rank_food
		FROM sales s
		JOIN menu m ON s.product_id = m.product_id
		GROUP BY DATE_FORMAT(s.order_date, '%Y-%m'), s.product_id, m.product_name ) AS most_order_menu
WHERE rank_food = 1;

-- 12. Recreate the table output using the available data
SELECT
	s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    (CASE
		WHEN s.order_date < mb.join_date THEN 'N'
        WHEN s.order_date >= mb.join_date THEN 'Y'
        ELSE 'N' END) AS 'Members'
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mb ON s.customer_id = mb.customer_id;