-- Databricks notebook source
Create Schema DataCleaning;

-- COMMAND ----------

--- I am going to go complete data cleaning on ramdom data set using mysql.


-- COMMAND ----------

select * from DataCleaning.layoffs;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC In Data cleaning our first step is
-- MAGIC -- remove all the duplicates if any

-- COMMAND ----------


-- So now before making any changes in our data we need some sort of safe place where we save our original data if in future may be we need it.
-- so now first we will create a statging area where we copy our data and keep it safe or we can use the stagging area to do our actions and our main data will be same in the file that we have ingested.

create table DataCleaning.layoffs_staging
as select * from DataCleaning.layoffs;
-- here i have created a new table named layoffs_stagging and i have copied all the data from layoffs table to layoffs_stagging.


-- COMMAND ----------

-- lets see if the data is copied
select * from 
datacleaning.layoffs_staging;

-- COMMAND ----------

-- removing dublicates
-- first let us see if there are any duplicates in our data.

with cte as (
    select *,
    row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions order by date) as row_num
    from datacleaning.layoffs_staging
) 
select *
from cte
where row_num > 1;

-- like this we get the duplicate rows from our data
-- but now in mysql we cannot directly delete duplucates by using a cte.
-- so we will create a new table with row_num as a column and then we will delete the rows where row_num > 1



-- COMMAND ----------

-- created a new table 
create table DataCleaning.layoffs_staging1
like datacleaning.layoffs_staging;



-- in next block we will include a new column


-- COMMAND ----------

-- including a new columns
alter table DataCleaning.layoffs_staging1
add column row_num int;

-- COMMAND ----------

select * from datacleaning.layoffs_staging1;

-- COMMAND ----------

-- now we will add the data with row number as well 
insert into datacleaning.layoffs_staging1
 select *,
    row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions order by date) as row_num
    from datacleaning.layoffs_staging;


-- COMMAND ----------

select * from datacleaning.layoffs_staging1;

-- COMMAND ----------

-- now with the help of row_number we can easily delete the rows whose row_num is greater than 1

delete from 
datacleaning.layoffs_staging1
where row_num > 1;

-- COMMAND ----------

-- lets check if there are any rows whose row_num is > than 1
select *
from datacleaning.layoffs_staging1
where row_num >1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Step 1 complete and we have the non duplicate data in datacleaning.layoffs_stagging1

-- COMMAND ----------

-- Standrading the data
-- so basically we see if the data needs any chaange like extra spaces , mistakes anything and we make it right
-- first lets see our data and decide what to do
select *
from datacleaning.layoffs_staging1;

-- COMMAND ----------

-- we have some spaces in the naming ... so lets remove the spaces

select company , trim(company) as Trim_company
from datacleaning.layoffs_staging1;

-- COMMAND ----------

-- we have seen above that our trim company is more proper
-- so lets update that in our stagging2

update datacleaning.layoffs_staging1
set company = Trim(company);
-- lets check if it is reflected

select *
from datacleaning.layoffs_staging1;

-- COMMAND ----------

-- likewise we inspect all our data and make some changes to make our data standradized.

select  distinct industry
from datacleaning.layoffs_staging1
order by 1;

-- here we have same crypo in 3 rows. 
-- we can change it into Crypto for all the 3 rows.

-- COMMAND ----------

-- let us change the multiple names for crypto to Crypto

update datacleaning.layoffs_staging1
set industry = 'Crypto'
where industry like "Crypto%";

-- COMMAND ----------

-- lets see if the changes are made to our data.
select  distinct industry
from datacleaning.layoffs_staging1
order by 1;

-- COMMAND ----------

-- Now if we want to perform any analysis on date column it should be in data format
-- but in the data that we have the data column is in text format
-- lets change the data column to date format

select `date`,
       try_to_date(date, 'M/d/yyyy') as converted_date
from datacleaning.layoffs_staging1;


-- COMMAND ----------

-- lets now update it in stagging2

update datacleaning.layoffs_staging1
set `date` = try_to_date(`date`, 'M/d/yyyy');

-- COMMAND ----------

-- lets check if it is updated or not
select date
from datacleaning.layoffs_staging1;

-- COMMAND ----------

-- step 3
-- handling with null and blank values
-- first we will see our data and decide in which columns we have nulls or blank spaces.
select *
from datacleaning.layoffs_staging1;


-- COMMAND ----------

-- we print the column which has null values

select *
from datacleaning.layoffs_staging1
where total_laid_off = "NULL";

-- COMMAND ----------

-- Convert the string "NULL" into real NULL
UPDATE datacleaning.layoffs_staging1
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL';

UPDATE datacleaning.layoffs_staging1
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

UPDATE datacleaning.layoffs_staging1
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL';

-- COMMAND ----------

-- Fix genuinely blank fields (like Airbnb's missing industry)
UPDATE datacleaning.layoffs_staging1
SET industry = NULL
WHERE TRIM(industry) = '';

-- COMMAND ----------

-- Now that they're real NULLs, decide what to do with each column

-- This depends on the column's role:

--total_laid_off and percentage_laid_off both NULL → you genuinely have no numbers for that layoff event. These rows are usually kept (they still confirm layoffs happened at that company/date) but excluded from any SUM/AVG calculations — which SQL already does automatically once they're real NULLs.
--industry NULL → often fixable by self-join, since the same company usually appears in another row with the industry filled in:

MERGE INTO datacleaning.layoffs_staging1 AS t1
USING (
  SELECT DISTINCT company, industry
  FROM datacleaning.layoffs_staging1
  WHERE industry IS NOT NULL
) AS t2
ON t1.company = t2.company
   AND t1.industry IS NULL
WHEN MATCHED THEN
  UPDATE SET t1.industry = t2.industry;

-- COMMAND ----------

-- Decide on rows where BOTH key metrics are NULL
DELETE FROM datacleaning.layoffs_staging1
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- COMMAND ----------

UPDATE datacleaning.layoffs_staging1
SET country = TRIM(TRAILING '.' FROM country);

-- COMMAND ----------

-- cleaned data
select *
from datacleaning.layoffs_staging1;