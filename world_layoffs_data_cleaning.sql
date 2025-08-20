-- SQL Project - Data Cleaning


SELECT * 
FROM world_layoffs.layoffs;



-- I created a staging table to work on and clean the data. 
-- This keeps the raw dataset intact as a backup in case it’s needed later.
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;


-- For the data cleaning process, I followed these main steps:
-- 1. Checked for duplicates and removed them where necessary.
-- 2. Standardized the data and fixed errors.
-- 3. Reviewed and handled null values.
-- 4. Removed unnecessary columns and rows.


-- 1. Remove Duplicates
-- First, I checked the dataset for duplicate records.



SELECT *
FROM world_layoffs.layoffs_staging
;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		world_layoffs.layoffs_staging;



SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
-- I checked the company 'Oda' to confirm whether these entries were actual duplicates.

SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda'
;
-- These entries looked legitimate and should not be deleted. I made sure to review each row carefully for accuracy.

-- these are our real duplicates 
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;

-- These are the records I decided to delete, where the row number is greater than 1.  
-- I then structured the deletion query as follows:

WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE
;


WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;

-- I chose to create a new column to store row numbers, 
-- then delete rows where the row number is greater than 2, 
-- and finally remove the helper column once cleanup is complete.

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;


SELECT *
FROM world_layoffs.layoffs_staging
;

CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;

-- Now that the row numbers are assigned, I can delete rows where row_num is greater than 2.

DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;



-- 2. Standardize Data

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- While reviewing the 'industry' column, I noticed some null and empty values, so I investigated these rows further.
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- let's take a look at these
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';
-- looks fine 
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- I noticed that 'Airbnb' should be classified as 'Travel', but the value is missing in some rows.  
-- I applied a query to update null industry values based on other rows with the same company name.  
-- This approach scales well for large datasets, avoiding manual checks for each row.

-- I converted blank values to NULLs, as this makes them easier to handle during analysis.

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- After the update, I verified that all previously blank values are now set to NULL.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Next, I populated the NULL values where possible using existing non null values from other rows of the same company.

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- After the update, I found that Bally's was the only company without another row to fill its NULL values.
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ------------------------------------------------------------------------------------------------------

-- I noticed that the 'industry' column contains multiple variations of "Crypto".  
-- I standardized all of them to a single value: 'Crypto'.
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- now that's done. 

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

-- --------------------------------------------------

SELECT *
FROM world_layoffs.layoffs_staging2;

-- Everything looks consistent except for the 'country' column, where some entries have a trailing period like "United States"
-- I standardized these values by removing the trailing period.

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- After applying the update, I verified that all country entries are now consistent.
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;


-- I also cleaned and standardized the 'date' column to ensure consistent date formatting.
SELECT *
FROM world_layoffs.layoffs_staging2;

-- I used STR_TO_DATE to convert the text values in the 'date' column into proper DATE format.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- After converting the text values, I updated the column's data type to DATE for proper handling.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


SELECT *
FROM world_layoffs.layoffs_staging2;





-- 3. Review Null Values
-- I examined the null values in 'total_laid_off', 'percentage_laid_off', and 'funds_raised_millions'.  
-- I decided to leave them as NULLs since this makes calculations easier during the EDA phase.  
-- No changes were needed for these columns.

-- 4. Remove Unnecessary Columns and Rows
-- I identified and removed columns and rows that were not useful for analysis.
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- I deleted rows that contained unusable or irrelevant data to clean the dataset further.
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT * 
FROM world_layoffs.layoffs_staging2;