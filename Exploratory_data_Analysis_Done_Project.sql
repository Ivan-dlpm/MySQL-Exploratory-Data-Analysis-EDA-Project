-- Exploratory Data Analysis 

select *
from layoffs_staging2;

-- here we see time span of data collection, from 2020-03-11 to 2023-03-06
select min(`date`),max(`date`)
from layoffs_staging2;

-- here we see which companies laid off the most amount of employees over the time span of data collection, top: amazon 
select company, sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 Desc;

-- here we can see which companies went totally out of business, laying off 100 percent of their workers 
select *
from layoffs_staging2
where percentage_laid_off = 1 ;

-- here we see which industries had the most layoffs in descending order, top: consumer   
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry 
order by 2 desc ;

-- here we see which contries layed off the most people in in descending order, top: united states 
select country, sum(total_laid_off)
from layoffs_staging2
group by country 
order by 2 desc ;

-- here we see during which year were the most amount of people layed off, top: 2022, 
-- Agaian this is just during the data collecting year, we do not have data for the full year of 2023 or 2020 
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 desc ;

-- here we see which type of company 'stage' laid off the most people, top: post-IPO
-- this data could be misleading, post-IPO comapnies also hire the most people
-- we could use avg percentage to have a better read on which stage did companies layed off the most people, top: seedm 
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc ;

-- top: seed companies during the period of 2020-03-11 to 2023-03-06 fired on average 70 of their employees 
select stage, avg(percentage_laid_off)
from layoffs_staging2
group by stage
order by 2 desc ;

-- rolling total, adding up total layoffs as months go on.
select substring(`date`,1,7) AS `Month`, Sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not Null
Group by `Month`
order by 1 asc;

with rolling_total as 
(
select substring(`date`,1,7) AS `Month`, Sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not Null
Group by `Month`
order by 1 asc
)
select `Month`, total_off, 
sum(total_off) over (order by `Month`) as rolling_total 
from rolling_total;

-- raking top 5 companies  based on who laid off the most employees that year, from 2020-03-11 to 2023-03-06

select company, year (`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year (`date`)
order by 3 desc;

with company_year (company, years, total_laid_off) as
(
select company, year (`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as
(
select *, 
dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null 
)
select *
from company_year_rank
where ranking <= 5 ;
