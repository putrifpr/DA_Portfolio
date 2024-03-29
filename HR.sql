USE hr;

SELECT * FROM human_resource;

ALTER TABLE human_resource
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;
DESCRIBE human_resource;

-- update kolom birthdate
UPDATE human_resource
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN 
		DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN 
		DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;
SELECT birthdate FROM human_resource;

ALTER TABLE human_resource MODIFY COLUMN birthdate DATE;

SELECT hire_date FROM human_resource;
UPDATE human_resource
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN 
		DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN 
		DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;
-- update kolom termdate
SELECT termdate FROM human_resource;
UPDATE human_resource
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE human_resource
SET termdate = NULL
WHERE termdate = '0000-00-00';

ALTER TABLE human_resource MODIFY COLUMN hire_date DATE;

SELECT birthdate, age FROM human_resource;

-- add kolom umur
ALTER TABLE human_resource ADD COLUMN age INT;
UPDATE human_resource
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE()); 

SELECT
	MIN(age) as youngest,
    MAX(age) as oldest
FROM human_resource;

SELECT COUNT(*) FROM human_resource
WHERE age < 18;

-- ANALISIS DATA --

-- 1. Total employee
SELECT
	COUNT(*) AS total_employee
FROM human_resource
WHERE age >= 18 AND termdate IS NULL;

-- 1b. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(gender) AS total_gender
FROM human_resource
WHERE age >= 18 AND termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(race) AS ethic
FROM human_resource
WHERE age >= 18 AND termdate IS NULL
GROUP BY race
ORDER BY COUNT(race) DESC;

-- 3. What is the age distribution of employees in the company?
SELECT
	CASE
		WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    gender,
    COUNT(*) AS age_count_group
FROM human_resource
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(location) AS total
FROM human_resource
WHERE age >=18 AND termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT
	ROUND(AVG(DATEDIFF(termdate, hire_date))/365, 3) AS avg_employment_year
FROM human_resource
WHERE termdate IS NOT NULL AND termdate <= CURDATE() AND age >= 18;

-- 6. How does the gender distribution vary across departements and job titles?
SELECT 
	department,
    jobtitle,
    gender,
    COUNT(gender) AS total_gender
FROM human_resource
WHERE age >= 18 AND termdate IS NULL
GROUP BY gender, department, jobtitle
ORDER BY gender;

-- 7. What is the distribution of job titles across the company?
SELECT 
    jobtitle,
    COUNT(jobtitle) AS total_employee
FROM human_resource
WHERE age >= 18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY COUNT(jobtitle) DESC;

-- 8. Which department has the highest turnover rate?
SELECT
	department,
    (layoff_emp / total_count) as percentage_layoff_dept
FROM (SELECT
			department,
			COUNT(*) AS total_count, -- buat hitung total employee per dept
			SUM(
				CASE
					WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1
					ELSE 0
				END
				) AS layoff_emp -- buat hitung count termdate (sebelum waktu terkini + gak null)
		FROM human_resource
		WHERE age >= 18
		GROUP BY department) AS layoff_data_table
GROUP BY department
ORDER BY (layoff_emp / total_count) DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT
	location,
	location_state,
	COUNT(location_city) as total
FROM human_resource
WHERE age >= 18 AND termdate IS NULL
GROUP BY location, location_state
ORDER BY COUNT(location_city) DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT DISTINCT
	year,
    hires,
    layoff_emp,
    (hires - layoff_emp) AS active_emp
FROM (SELECT DISTINCT
			YEAR(hire_date) AS year,
			COUNT(*) AS hires,
			SUM(
						CASE
							WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1
							ELSE 0
						END
						) AS layoff_emp
		FROM human_resource
        WHERE age >= 18
        GROUP BY YEAR(hire_date)
        ) AS emp_by_year
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
SELECT
	department,
    ROUND(AVG(DATEDIFF(termdate, hire_date))/365, 0) AS avg_lama_jabatan
FROM human_resource
GROUP BY department
ORDER BY ROUND(AVG(DATEDIFF(termdate, hire_date))/365, 0) DESC;

-- 12. Persebaran Employee di tiap Negara
SELECT
	location_state,
    COUNT(location_state)
FROM human_resource
GROUP BY location_state;