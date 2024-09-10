-- Data Cleaning


SELECT *
FROM world_layoffs.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Decide on Null or Blank Values
-- Remove Unwanted Columns where Necessary


-- Create a Working Document (Table) from the Existing/Given Table


CREATE TABLE layoffs_staging1
LIKE world_layoffs.layoffs;



SELECT * 
FROM layoffs_staging1;


INSERT INTO layoffs_staging1
SELECT * 
FROM layoffs;


SELECT *
FROM layoffs_staging1;


-- Identifying Duplicates

SELECT *, 
Row_NUMBER() 
OVER(PARTITION BY company,location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging1;

-- Filtering Out the Duplicates


WITH duplicates_cte AS (
SELECT *, 
ROW_NUMBER() 
OVER(PARTITION BY company,location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging1
)
SELECT * 
FROM duplicates_cte 
WHERE row_num >1 ;


CREATE TABLE layoffs_staging2 
LIKE layoffs_staging1;

ALTER TABLE layoffs_staging2
ADD row_num INT;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() 
OVER(PARTITION BY company,location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country,funds_raised_millions) AS row_num
FROM layoffs_staging1;

-- Removing the Identified Duplicates 

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * FROM layoffs_staging2;

-- Standardizing the Data

SELECT company , TRIM(company) AS company
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);



SELECT DISTINCT(industry)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2 
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2 
SET industry ='Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT(country) 
FROM layoffs_staging2
ORDER BY country;   

-- Two distinct United States identified in the (country) column above need standardization.

UPDATE layoffs_staging2
SET country ='United States'
WHERE country LIKE 'United States%';



SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date` FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Remove Null and Blank Columns
SELECT *
FROM layoffs_staging2 
WHERE industry is NULL
OR industry ='';

SELECT * FROM 
layoffs_staging2 
WHERE company ='Airbnb';


SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
     ON t1.company =t2.company
     AND t1.location =t2.location
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry ='NULL'
WHERE industry ='';
 
 
 UPDATE layoffs_staging2 t1
 JOIN layoffs_staging2 t2
   ON t1.company =t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * FROM layoffs_staging2;

-- Removing Unwanted Columns

DELETE 
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;


DELETE 
FROM layoffs_staging2
WHERE `date` IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL;