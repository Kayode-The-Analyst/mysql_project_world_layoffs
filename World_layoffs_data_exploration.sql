-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off),Min(total_laid_off),Max(percentage_laid_off)
,Min(percentage_laid_off) FROM layoffs_staging2;


SELECT company, country, industry, `date`, YEAR(`date`) AS year
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY company ASC,country ASC;



SELECT company,country, SUM(total_laid_off) AS layoffs_new
FROM layoffs_staging2
GROUP BY company,country
ORDER BY layoffs_new;

WITH num_laid_off AS
(
SELECT company,country, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
GROUP BY company,country
ORDER BY layoffs
)
SELECT * FROM num_laid_off
WHERE layoffs IS NOT NULL
ORDER BY layoffs DESC;


SELECT industry, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY layoffs;

WITH layoffs_cte AS
(
SELECT industry, SUM(total_laid_off) AS layoffs1
FROM layoffs_staging2
GROUP BY industry
ORDER BY layoffs1 DESC
)
SELECT industry,layoffs1
FROM layoffs_cte
WHERE industry IS NOT NULL;





-- Date Range of layoffs

SELECT MIN(`date`),MAX(`date`) 
FROM layoffs_staging2;

SELECT * 
FROM  layoffs_staging2
WHERE YEAR(`date`) < 2022
ORDER BY YEAR(`date`) DESC ;

SELECT YEAR(`date`) AS `date` , SUM(total_laid_off) AS number_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC ;


SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `month`
ORDER BY `month`;


WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY `month`
ORDER BY `month`
)
SELECT month,total, SUM(total) OVER(ORDER BY `month`) as rolling_total
FROM rolling_total;


SELECT company, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY layoffs DESC;

SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY layoffs DESC;

WITH company_year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY layoffs DESC
), company_year_rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year)
SELECT * FROM company_year_rank
WHERE ranking <=5;


