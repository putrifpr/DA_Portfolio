USE latihan;

SELECT * FROM ds_salaries;
DESCRIBE ds_salaries;

ALTER TABLE ds_salaries
MODIFY COLUMN work_year CHAR(4);

UPDATE ds_salaries
SET employment_type = 
	CASE
		WHEN employment_type = 'FT' THEN 'Full Time'
        WHEN employment_type = 'CT' THEN 'Contract'
        WHEN employment_type = 'FL' THEN 'Freelance'
        WHEN employment_type = 'PT' THEN 'Part Time'
	END;
    
UPDATE ds_salaries
SET experience_level = 
	CASE
		WHEN experience_level = 'SE' THEN 'Senior'
        WHEN experience_level = 'EN' THEN 'Entry Level'
        WHEN experience_level = 'MI' THEN 'Mid Level'
        WHEN experience_level = 'EX' THEN 'Executive'
	END;

-- 1. Gaji IT (scorecard -avg-)
	SELECT
        AVG(salary_in_usd) AS avg_salary
	FROM ds_salaries;
    
-- 2. Rata-rata rasio remote (scorecard)
	SELECT
		AVG(remote_ratio) AS avg_ratio
	FROM ds_salaries;
    
-- 3. Bagaimana distribusi gaji Data Science berdasarkan pengalaman kerja?
SELECT
	work_year,
    experience_level,
    AVG(salary_in_usd) as salary
FROM ds_salaries
GROUP BY work_year, experience_level
ORDER BY experience_level;

-- 4. Apakah ada perbedaan signifikan dalam gaji antara tipe pekerjaan (employment_type)?
SELECT
	employment_type,
	AVG(salary_in_usd) AS avg_salary
FROM ds_salaries
GROUP BY employment_type
ORDER BY avg_salary;

-- 5. Rata-rata gaji berdasarkan job title per tahunnya (table)
SELECT
	work_year,
    job_title,
    AVG(salary_in_usd) AS avg_salary
FROM ds_salaries
GROUP BY job_title, work_year
ORDER BY job_title;

-- 6. Rata-rata gaji IT per tahunnya (bar chart)
SELECT
	work_year,
    AVG(salary_in_usd) AS avg_salary
FROM ds_salaries
GROUP BY work_year
ORDER BY work_year DESC;

-- 7. Persen rata-rata kenaikan gaji IT per-tahunnya (scorecard)
SELECT
	ROUND(AVG(((t1.avg_salary - t2.avg_salary) / t2.avg_salary)), 3) AS persentase_kenaikan
FROM (
		SELECT
			work_year,
			AVG(salary_in_usd) AS avg_salary
		FROM ds_salaries
		GROUP BY work_year
		ORDER BY work_year) AS t1
JOIN ( 
		SELECT
			work_year,
			AVG(salary_in_usd) AS avg_salary
		FROM ds_salaries
		GROUP BY work_year
		ORDER BY work_year) AS t2 ON t1.work_year = t2.work_year + 1;

-- cek pekerja 'analyst'
SELECT
	COUNT(DISTINCT job_title)
FROM ds_salaries
WHERE job_title LIKE '%analyst%';

-- 8. Rata-rata gaji berdasarkan ukuran perusahaan
SELECT
	company_size,
    AVG(salary_in_usd) AS avg_salary
FROM ds_salaries
GROUP BY company_size;

-- 9. Jumlah karyawan berdasarkan company location (tree maps)
SELECT 
    CASE 
        WHEN total_employee < 20 THEN 'Lainnya'
        ELSE company_location
    END AS company_location_grouped,
    SUM(total_employee) AS total_employee
FROM (
    SELECT 
        company_location,
        COUNT(*) AS total_employee
    FROM ds_salaries
    GROUP BY company_location
) AS subquery
GROUP BY 
    (CASE 
        WHEN total_employee < 20 THEN 'Lainnya'
        ELSE company_location
    END)
ORDER BY 
    total_employee DESC;

-- 10. Persentase pegawai yang rantau dan tidak (pie chart)
SELECT
	mobility,
	COUNT(*) AS total_employee
FROM (
SELECT
	employee_residence,
	company_location,
	(CASE
		WHEN employee_residence = company_location THEN 'Tidak Rantau'
		ELSE 'Rantau'
		END) AS mobility
FROM ds_salaries) AS mobility_employee
GROUP BY mobility;

SELECT
	employment_type,
    COUNT(*) AS total_employee
FROM ds_salaries
GROUP BY employment_type;


-- TOP 5 posisi dengan jumlah pegawai terbanayak
SELECT
	job_title,
    COUNT(*) AS total_employee
FROM ds_salaries
GROUP BY job_title
ORDER BY total_employee DESC;

-- Rata-rata gaji dan total employee berdasarkan experience level
SELECT
	experience_level,
    COUNT(*) AS total_employee,
    AVG(salary_in_usd) AS avg_salary
FROM ds_salaries
GROUP BY experience_level;

-- Pengelompokkan gaji
SELECT
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END) AS salary_grade,
    COUNT(*) AS total
FROM ds_salaries
GROUP BY (CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END)
ORDER BY total;

SELECT
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END) AS salary_grade,
    experience_level,
    COUNT(*) AS total
FROM ds_salaries
WHERE job_title = 'Data Engineer' -- Menyertakan kondisi filter menggunakan WHERE
GROUP BY 
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END),
    experience_level
ORDER BY total;

SELECT
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END) AS salary_grade,
    COUNT(*) AS total
FROM ds_salaries
WHERE job_title = 'Data Engineer' -- Menyertakan kondisi filter menggunakan WHERE
GROUP BY 
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END)
ORDER BY total;

SELECT
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END) AS salary_grade,
    COUNT(*) AS total
FROM ds_salaries
WHERE job_title = 'Data Analyst' -- Menyertakan kondisi filter menggunakan WHERE
GROUP BY 
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END)
ORDER BY total;

SELECT
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END) AS salary_grade,
    COUNT(*) AS total
FROM ds_salaries
WHERE job_title NOT IN ('Data Engineer', 'Data Scientist', 'Data Analyst')
GROUP BY 
	(CASE
		WHEN salary_in_usd < 100000 THEN 'Low'
        WHEN salary_in_usd BETWEEN 100000 AND 150000 THEN 'Medium'
        WHEN salary_in_usd BETWEEN 150001 AND 200000 THEN 'High'
        ELSE 'Super High'
	END)
ORDER BY total;