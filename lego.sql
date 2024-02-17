USE lego;

-- CREATE VIEW
CREATE VIEW analytics_main AS
SELECT 
	s.set_num,
    s.name AS set_name,
    s.year,
    s.theme_id,
    CAST(s.num_parts AS FLOAT) AS num_parts,
    t.name AS theme_name,
    t.parent_id,
    p.name AS parent_theme_name
FROM sets s
LEFT JOIN themes t
	ON s.theme_id = t.id
LEFT JOIN themes p
	ON t.parent_id = p.id;

-- ALTER VIEW
ALTER VIEW analytics_main AS
SELECT 
	s.set_num,
    s.name AS set_name,
    s.year,
    s.theme_id,
    CAST(s.num_parts AS FLOAT) AS num_parts,
    t.name AS theme_name,
    t.parent_id,
    p.name AS parent_theme_name,
    (CASE
		WHEN s.year BETWEEN 1901 AND 2000 THEN '20th Century'
        WHEN s.year BETWEEN 2001 AND 2100 THEN '21st Century'
        END) AS century
FROM sets s
LEFT JOIN themes t
	ON s.theme_id = t.id
LEFT JOIN themes p
	ON t.parent_id = p.id;
    
-- 1. What is total number of part per theme?
SELECT
	theme_name,
    SUM(num_parts) AS total_numparts
FROM analytics_main
WHERE parent_theme_name IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 2. What is the total number of parts per year
SELECT
	year,
    SUM(num_parts) AS total_numparts
FROM analytics_main
WHERE parent_theme_name IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

-- 3. How many sets where created in each Century in the dataset
SELECT
	century,
    COUNT(set_num) AS total_set_num
FROM analytics_main
WHERE parent_theme_name IS NOT NULL
GROUP BY century;

-- 4. What percentage of sets ever released in the 21st Century were Trains Themed
WITH century_set_data AS (
    SELECT 
        century,
        theme_name,
        COUNT(set_num) AS total_set_num
    FROM analytics_main
    WHERE century = '21st Century'
    GROUP BY century, theme_name
)
SELECT
	SUM(total_set_num),
    SUM(percentage)
FROM (
		SELECT 
			*,
			SUM(total_set_num) OVER() AS total,
			(total_set_num / sum(total_set_num) OVER())*100 AS percentage
		FROM century_set_data ) AS subquery -- agar totalnya '16097' bukan dari total milik '%train%' aja
WHERE theme_name LIKE '%train%';

SELECT
	century,
    theme_name,
    (total_set_num/total)*100 AS percentage
FROM (
		SELECT
			*,
			SUM(total_set_num) OVER() AS total
		FROM (
				SELECT 
					century,
					theme_name,
					COUNT(set_num) AS total_set_num
				FROM analytics_main
				WHERE century = '21st Century'
				GROUP BY century, theme_name ) AS century_set_data ) AS csd_total
WHERE theme_name LIKE '%train%';
                
-- 5. What was the popular themes by year in terms of sets released in the 21st Century
SELECT * FROM (
SELECT
	year,
    theme_name,
    COUNT(theme_name) AS total_released,
    ROW_NUMBER() OVER(PARTITION BY year ORDER BY COUNT(theme_name) DESC) AS rank_in_year
FROM analytics_main
WHERE century = '21st Century' AND parent_theme_name IS NOT NULL
GROUP BY year, theme_name ) AS rank_theme_in_year
WHERE rank_in_year = 1;

-- 6. What is the most produced color of lego ever in terms of quantity of parts?
SELECT
	c.name AS colour,
    COUNT(p.part_cat_id) AS total
FROM colors c
JOIN parts p
	ON c.id = p.part_cat_id
GROUP BY c.name
ORDER BY 2 DESC;

SELECT
	c.name AS colour,
    COUNT(e.color_id) AS total
FROM colors c
JOIN elements e
	ON c.id = e.color_id
GROUP BY c.name
ORDER BY 2 DESC;

-- 7. Berapa jumlah sets yang diproduksi per tahunnya?


