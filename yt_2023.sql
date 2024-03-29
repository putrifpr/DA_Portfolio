CREATE DATABASE yt_2023;

USE yt_2023;
SELECT * FROM youtube;
DESCRIBE youtube;

ALTER TABLE youtube
ADD COLUMN date_created DATE;

UPDATE youtube
SET created_month =
		CASE
			WHEN created_month = 'Jan' THEN 01
			WHEN created_month = 'Feb' THEN 02
			WHEN created_month = 'Mar' THEN 03
			WHEN created_month = 'Apr' THEN 04
			WHEN created_month = 'May' THEN 05
			WHEN created_month = 'Jun' THEN 06
			WHEN created_month = 'Jul' THEN 07
			WHEN created_month = 'Aug' THEN 08
			WHEN created_month = 'Sep' THEN 09
			WHEN created_month = 'Oct' THEN 10
			WHEN created_month = 'Nov' THEN 11
			WHEN created_month = 'Dec' THEN 12
		END;

UPDATE youtube
SET date_created = DATE_FORMAT(CONCAT(created_year,'-',created_month,'-',created_date), '%Y-%m-%d');

ALTER TABLE youtube
DROP COLUMN created_year,
DROP COLUMN created_month,
DROP COLUMN created_date;

-- Total Youtuber di 2023
SELECT
	COUNT(DISTINCT Youtuber) AS total_youtuber
FROM youtube;

-- Total Youtuber di 2023 berdasarkan category
SELECT
	category,
	COUNT(DISTINCT Youtuber) AS total_youtuber
FROM youtube
GROUP BY category
ORDER BY total_youtuber DESC;

-- Total Views berdasarkan category
SELECT
	category,
    SUM(video_views) AS total_views
FROM youtube
GROUP BY category
ORDER BY total_views DESC;

-- Negara dengan jumlah youtuber terbanyak
SELECT
	Country,
    COUNT(Youtuber) AS total_youtuber
FROM youtube
GROUP BY Country
ORDER BY total_youtuber DESC;

-- Negara dengan total views terbanyak
SELECT
	Country,
    SUM(video_views) AS total_view
FROM youtube
GROUP BY Country
ORDER BY total_view DESC;

-- Negara dengan total views terbanyak berdasarkan kategori 'Music'
SELECT
	Country,
    SUM(video_views) AS total_views
FROM youtube
WHERE category = 'Music'
GROUP BY Country
ORDER BY total_views DESC;

-- Views growth by year
SELECT
	YEAR(date_created) AS date_year,
    SUM(video_views) AS total_views
FROM youtube
WHERE YEAR(date_created) != '1970'
GROUP BY YEAR(date_created)
ORDER BY date_year;

-- Rata-rata pertumbuhan views per tahun
SELECT 
    AVG(ABS(selisih)) AS rata_rata_selisih
FROM
    (SELECT 
        t1.date_year,
        t1.total_views,
        (t1.total_views - t2.total_views) AS selisih
    FROM
        (
			SELECT
				YEAR(date_created) AS date_year,
				SUM(video_views) AS total_views
			FROM youtube
			GROUP BY YEAR(date_created)
			ORDER BY date_year ) AS t1
    JOIN (
			SELECT
				YEAR(date_created) AS date_year,
				SUM(video_views) AS total_views
			FROM youtube
			GROUP BY YEAR(date_created)
			ORDER BY date_year ) AS t2 ON t1.date_year = t2.date_year + 1) AS selisih_tahun;
  
-- Persentase selisih pertumbuhan views per tahun
SELECT 
    ROUND(AVG(((t1.total_views - t2.total_views) / t2.total_views)* 100), 3) AS persentase_pertumbuhan
FROM
    (
        SELECT
            YEAR(date_created) AS date_year,
            SUM(video_views) AS total_views
        FROM
            youtube
        GROUP BY YEAR(date_created)
        ORDER BY date_year
    ) AS t1
JOIN (
        SELECT
            YEAR(date_created) AS date_year,
            SUM(video_views) AS total_views
        FROM
            youtube
        GROUP BY YEAR(date_created)
        ORDER BY date_year
    ) AS t2 ON t1.date_year = t2.date_year + 1;

-- Tren berkembangnya jumlah youtuber per tahun        
SELECT
    date_year,
    SUM(total_youtuber) OVER (ORDER BY date_year) AS cumulative_total_youtuber
FROM (
    SELECT
        YEAR(date_created) AS date_year,
        COUNT(DISTINCT Youtuber) AS total_youtuber
    FROM
        youtube
    WHERE YEAR(date_created) != '1970'
    GROUP BY YEAR(date_created)
    ORDER BY date_year
) AS youtuber_by_year;

-- Views youtube kategori musik per tahun nya
SELECT
	YEAR(date_created) AS year_date,
    SUM(video_views) AS total_views
FROM youtube
WHERE category = 'Music'
GROUP BY YEAR(date_created)
ORDER BY year_date;