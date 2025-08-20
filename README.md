# World Layoffs Data Cleaning Project

## Overview
For this project, I worked on cleaning and standardizing a dataset of global layoffs. The main goal was to prepare the data for further analysis by removing duplicates, fixing inconsistent values, and handling nulls. 

I wrote SQL queries to systematically clean the dataset and create a reliable version that could be used for exploration or reporting.

---

## Steps I Took

1. **Created a staging table**  
   I made a copy of the original dataset so the raw data stays intact as a backup. All cleaning operations were done on the staging table.

2. **Removed duplicates**  
   I identified duplicate rows using SQL’s `ROW_NUMBER()` function and deleted rows that were redundant while keeping at least one copy of each record.

3. **Standardized data**  
   - Updated inconsistent entries in the `industry` and `country` columns (for example, standardizing multiple variations of "Crypto" to a single value).  
   - Converted blank fields to `NULL` for easier analysis.  
   - Converted text dates to proper `DATE` format.

4. **Reviewed and handled null values**  
   I examined numeric columns such as `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions`. I kept nulls where appropriate to maintain accurate data and facilitate calculations during exploratory analysis.

5. **Removed unnecessary rows and columns**  
   Rows with completely missing critical information were deleted, and temporary helper columns used during cleaning were dropped.

---

## Key Notes
- The final cleaned table is ready for exploratory data analysis (EDA) or reporting.  
- All cleaning decisions were made to preserve data integrity while making the dataset easier to work with.  
- The project demonstrates my ability to handle real-world messy data using SQL and to apply systematic data cleaning methods.

---

## How to Run
1. Open the SQL file `world_layoffs_data_cleaning.sql` in your SQL client (e.g., MySQL Workbench, DBeaver, or VS Code with SQL extension).  
2. Execute the queries in order. The final table `layoffs_staging2` will contain the cleaned dataset.  
3. You can run `SELECT * FROM world_layoffs.layoffs_staging2;` to explore the cleaned data.

---

## Skills Demonstrated
- SQL for data cleaning and transformation  
- Handling duplicates, nulls, and inconsistent values  
- Creating and working with staging tables  
- Preparing data for analysis or reporting  

---

*Project created by [Your Name]*  
