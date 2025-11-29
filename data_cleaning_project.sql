-- data cleaning --


select *
from layoffs;

-- 1. remove dublicates 
-- 2. standarized the data 
-- 3. look through  null (none) / blank values. see if we can populate 
-- 4. remove any columns or rows that arent necesarry 

-- created the table 
create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

-- populated the table with data
insert layoffs_staging
select *
from layoffs;

-- cheking to remove dublicates 

select *,
row_number() over(
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1; 

-- rows in the 'duplicate_cte' that have a row_num greater than one show a duplicate in the 'layoffs_staging' table 
--  where row_num > 1; shows how many rows in the 'layoffs_staging' table have the same company, industry, total_laid_off, percentage_laid_off, `date` ex. 

-- checking which rows are duplicates 

select*
from layoffs_staging 
where company = 'Casper';
# there are three rows dedicated to casper, two of them represent the duplicate, we want to delete only one 

-- rows can not be deleted from cte
-- creating a table where row_number is a column, so we can delete does rows which have row_num > 1

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--  (`row_num` int) was added manually 


select *
from layoffs_staging2;

insert layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging;

-- table has been created 

-- checking where row_num is greater than 2 

select *
from layoffs_staging2
where row_num > 1; 

set sql_safe_updates = 0;

delete
from layoffs_staging2
where row_num > 1; 

select *
from layoffs_staging2
where row_num > 1; 

-- duplicate columss removed 

-- standardizing data 

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

-- cheking for corrections that could be made 

select distinct industry 
from layoffs_staging2
order by 1;

-- found error , three unique industries all representing the same thing 
-- `crypto`, `crypto currency`, `cryptocurrency`

select distinct industry 
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';

select distinct country 
from layoffs_staging2
order by 1;

-- found repeting country 'united states', united states.'

select distinct country 
from layoffs_staging2
where country like 'united states%';

-- way 1 
update layoffs_staging2
set country = 'United States'
where country like 'United States%';

-- way 2 -- this works for any country that may have a '.' at the end 

select distinct country, trim(trailing '.'from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.'from country)
where country like '%';


-- date column definition is set to 'text', in the future if we want to do analysis we could need the definition to be 'date'
-- we want to turn the defition of the date column from 'text' to 'date' 

UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'None';

select `date`,
str_to_date( `date`, '%m/%d/%Y')
from layoffs_staging2;

set sql_safe_updates = 0;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

select *
from layoffs_staging2;

-- date column has been set to definition 'date'
-- turning 'None' into nulls

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 'None';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'None';

-- populating null values where we can 

select *
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

-- not much that we can do with rows where `total_laid_off` is nulls and `percentage_laid_off` is null 
-- not enough information given 
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = 'None';

select *
from layoffs_staging2
where industry is null 
or industry = '';


-- if the rows which have industry as null or blank have other rows where company and location are the same, it is save to update the blanks with the populated industry 
-- we find three companies with blank in industry column 
-- to populate these blank cells we will use join to find the matching company with the populated industry column and then update 

set sql_safe_updates = 0;

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company 
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null;

-- set to null so there are no additional blanks 

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- now that each null  on t1 has a pair on t2 we can match and change themm 

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company 
set t1.industry = t2.industry 
where t1.industry is null 
and t2.industry is not null;


-- lets check Airbnb 

select *
from layoffs_staging2
where company = 'Airbnb';

-- lets check everything 

select *
from layoffs_staging2
where industry is null 
or industry = '';

select *
from layoffs_staging2
where company like 'Bally%';

-- all are populated except Bally's does not have another populated for industry to match it with, it will stay a null 
-- lets get rid of the rows which had null for total and percentage laid off, not enough information to make any assestment. 

delete 
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

-- lets take away the row_num column which is not in use anymore

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2

-- done :)-----------------------

-- 1. remove dublicates 
-- 2. standarized the data 
-- 3. look through  null (none) / blank values. see if we can populate 
-- 4. remove any columns or rows that arent necesarry 
