USE ds_jobs;

-- ANALISIS LOKASI DAN PERUSAHAAN --
-- 1. Lowongan di tiap kota (bar/pie/heatmap)
SELECT job_state, COUNT(*) AS total_jobvacancy
FROM dsjobs
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Perusahaan yang paling banyak membuka lowongan
SELECT `Company Name`, COUNT(*) AS total_jobvacancy
FROM dsjobs
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Rata-rata gaji berdasarkan lokasi (boxplot/bar)
SELECT job_state, AVG(min_salary) AS mean_min_salary, AVG(max_salary) AS mean_max_salary
FROM dsjobs
GROUP BY 1
ORDER BY 3 DESC;

-- ANALISIS GAJI --
-- 1. Rata-rata gaji berdasarkan skill yang dimiliki
-- 2. Rata-rata gaji dari total lowongan yang ditawarkan perusahaan
SELECT `Company Name`, AVG(avg_salary)
FROM dsjobs
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Rata-rata minimal dan maksimal gaji berdasarkan tipe pekerjaan (bar/line/dotplot/lollipop)
SELECT `Job Type`, AVG(min_salary) AS mean_min_salary, AVG(max_salary) AS mean_max_salary, AVG(max_salary)-AVG(min_salary) AS difference_salary
FROM dsjobs
GROUP BY 1
ORDER BY 4 DESC;

-- ANALISIS SKILL --
-- 1. Skill terbanyak yang dibutuhkan setiap lowongan (horizontal bar/treemap)
SELECT 'python' AS skill, SUM(python) AS total FROM dsjobs
UNION ALL
SELECT 'excel', SUM(excel) FROM dsjobs
UNION ALL
SELECT 'hadoop', SUM(hadoop) FROM dsjobs
UNION ALL
SELECT 'spark', SUM(spark) FROM dsjobs
UNION ALL
SELECT 'aws', SUM(aws) FROM dsjobs
UNION ALL
SELECT 'tableau', SUM(tableau) FROM dsjobs
UNION ALL
SELECT 'sql', SUM(`sql`) FROM dsjobs
UNION ALL
SELECT 'power_bi', SUM(power_bi) FROM dsjobs
UNION ALL
SELECT 'big_data', SUM(big_data) FROM dsjobs
ORDER BY 2 DESC;

-- 2. Frekuensi skill 'python' paling sering digunakan dengan skill apa? (dotplot/lollipop)
SELECT 
    'excel' AS skill, SUM(python * excel) AS co_occurrence_count FROM dsjobs
UNION ALL
SELECT 
    'hadoop', SUM(python * hadoop) FROM dsjobs
UNION ALL
SELECT 
    'spark', SUM(python * spark) FROM dsjobs
UNION ALL
SELECT 
    'aws', SUM(python * aws) FROM dsjobs
UNION ALL
SELECT 
    'tableau', SUM(python * tableau) FROM dsjobs
UNION ALL
SELECT 
    'sql', SUM(python * `sql`) FROM dsjobs
UNION ALL
SELECT 
    'power_bi', SUM(python * power_bi) FROM dsjobs
UNION ALL
SELECT 
    'big_data', SUM(python * big_data) FROM dsjobs
ORDER BY co_occurrence_count DESC;

-- 3. Nilai rata-rata minimal dan maksimal gaji untuk setiap skill (grouped bar)
SELECT 
    skill,
    AVG(min_salary) AS mean_min_salary,
    AVG(max_salary) AS mean_max_salary,
    AVG(max_salary) - AVG(min_salary) AS diff_salary
FROM (
    SELECT 
        min_salary, 
        max_salary,
        CASE 
            WHEN python = 1 THEN 'python'
            WHEN excel = 1 THEN 'excel'
            WHEN hadoop = 1 THEN 'hadoop'
            WHEN spark = 1 THEN 'spark'
            WHEN aws = 1 THEN 'aws'
            WHEN tableau = 1 THEN 'tableau'
            WHEN `sql` = 1 THEN 'sql'
            WHEN power_bi = 1 THEN 'power_bi'
            WHEN big_data = 1 THEN 'big_data'
        END AS skill
    FROM dsjobs
) AS skills
WHERE skill IS NOT NULL
GROUP BY skill
ORDER BY diff_salary DESC;

-- ANALISA BERDIRINYA --
-- 1. Rata-rata usia perusahaan yang tercantum (scorecard)
SELECT
	AVG(company_age) AS avg_company_age
FROM (
	SELECT
		DISTINCT `Company Name`,
		company_age
	FROM dsjobs) AS comp_age;

-- 2. Taksiran minimal dan maksimal gaji terhadap perusahaan yang berusia >31 tahun dan <31 tahun (grouped bar/range plot)
SELECT
	age_of_company,
	AVG(min_salary) AS mean_min_salary,
    AVG(max_salary) AS mean_max_salary,
    AVG(max_salary)-AVG(min_salary) AS diff_salary
FROM (
		SELECT
			DISTINCT `Company Name`,
			min_salary,
			max_salary,
			company_age,
			CASE
				WHEN company_age BETWEEN 1 AND 31 THEN 'Under <=31 years'
				WHEN company_age > 31 THEN 'Above >31 years'
				WHEN company_age = 0 THEN 'Unknown'
			END AS age_of_company
		FROM dsjobs ) AS comp_age
WHERE age_of_company != 'Unknown'
GROUP BY 1
ORDER BY 4 DESC;

-- 3. Rata-rata rating perusahaan yang sudah berdiri lebih dari 31 tahun atau kurang dari 31 tahun (score card)
SELECT
    age_of_company,
	ROUND(AVG(`Rating`),2) AS `Avg Rating`
FROM (
    SELECT
		DISTINCT `Company Name`,
		`Rating`,
		company_age,
		CASE
			WHEN company_age BETWEEN 1 AND 31 THEN 'Under 32 years'
			WHEN company_age > 31 THEN 'Above 31 years'
			WHEN company_age = 0 THEN 'Unknown'
		END AS age_of_company
	FROM dsjobs ) AS rating_company
WHERE age_of_company != 'Unknown'
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Sector perusahaan dengan rating minimal 3.6 (ada yg salah krn company name bisa double)
SELECT
	`Sector`,
    COUNT(`Sector`) AS total
FROM (
	SELECT
		DISTINCT `Company Name`,
		`Sector`,
		`Rating`
	FROM dsjobs
	WHERE `Sector` != 'na' ) AS rating_sector
WHERE `Rating` > 3.6
GROUP BY 1
ORDER BY 2 DESC;

-- 5. Total perusahaan dengan rating di atas 3.6
SELECT
	COUNT(DISTINCT `Company Name`) AS total_company
FROM dsjobs
WHERE `Rating` > 3.6;

-- ANALISIS TREN PEKERJAAN BERDASARKAN SEKTOR --
-- 1. Skill yang paling banyak digunakan setiap sektor
SELECT
	`Sector`,
    SUM(python) AS total_python,
    SUM(excel) AS total_excel,
    SUM(hadoop) AS total_hadoop,
    SUM(spark) AS total_spark,
    SUM(aws) AS total_aws,
    SUM(tableau) AS total_tableau,
    SUM(`sql`) AS total_sql,
    SUM(power_bi) AS total_power_bi,
    SUM(big_data) AS total_big_data
FROM dsjobs
WHERE `Sector` != 'na'
GROUP BY 1;

-- 2. Gaji minimal dan maksimal setiap sektor
SELECT
	`Sector`,
    COUNT(*) AS total_sector,
    MIN(min_salary) AS minmin_salary_sector,
    AVG(min_salary) AS mean_min_salary,
    MAX(max_salary) AS maxmin_salary_sector,
	MIN(max_salary) AS minmax_salary_sector,
    AVG(max_salary) AS mean_max_salary,
	MAX(max_salary) AS maxmax_salary_sector
FROM dsjobs
WHERE `Sector` != 'na'
GROUP BY 1
ORDER BY 7 DESC;

-- 3. Perusahaan dengan rating di atas 3.6
SELECT
	DISTINCT `Company Name`,
    `Sector`,
    `Rating`
FROM dsjobs
WHERE `Sector` != 'na' AND `Rating` > 3.6
ORDER BY 3 DESC;

SELECT DISTINCT COUNT(DISTINCT `Company Name`) AS Total_Company
FROM dsjobs;

SELECT DISTINCT COUNT(DISTINCT `Sector`) AS Total_Sector
FROM dsjobs;