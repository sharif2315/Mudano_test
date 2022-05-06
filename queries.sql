-- List countries with income level of "Upper middle income"
SELECT name
FROM world_bank_country_data
WHERE "incomeLevel" = 'Upper middle income';


-- List countries with income level of 'Low income' PER region
-- count per region
SELECT region, name
FROM world_bank_country_data
where "incomeLevel" = 'Low income'
ORDER BY region;


-- Find the region with the highest proportion of High Income countries
-- All of US countries ar 'high income' hence 100%
SELECT wbcd.region,
       count(name) AS total_countries,
       num_high_income,
       round(100*cast(num_high_income as decimal) / count(name),2) AS "%_of_high_income_from_region"
FROM world_bank_country_data wbcd
LEFT JOIN (
    SELECT region, count(name) AS num_high_income
    from world_bank_country_data
    where "incomeLevel" = 'High income'
    group by region
    ) AS high_income_countries

ON wbcd.region = high_income_countries.region
WHERE (wbcd.region != 'Aggregates' OR NULL) and num_high_income > 0
group by wbcd.region, num_high_income
ORDER BY 4 desc
LIMIT 1;

-- Alternative method using CASE WHEN
-- SELECT region, SUM(CASE WHEN incomeLevel = 'High Income' THEN 1 ELSE 0 END) high, count(name),
-- SUM(CASE WHEN incomeLevel = 'High Income' THEN 1 ELSE 0 END) / count(name) proportion
-- FROM wb
-- GROUP BY 1
-- ORDER BY 3 ASC
-- LIMIT 1


-- 4. Calculate cumulative/running value of GDP per region ordered by income from lowest to highest and country name.
SELECT wbcd.region,
       round(SUM(cast(gdp."2019" as decimal)),2) as "2019",
       round(SUM(cast(gdp."2020" as decimal)),2) as "2020",
       round(SUM(cast(gdp."2021" as decimal)),2) as "2021",
       round(SUM(cast(gdp."2022" as decimal)),2) as "2022",
       round(SUM(cast(gdp."2023" as decimal)),2) as "2023"
FROM world_bank_country_data AS wbcd
INNER JOIN gdp_data as gdp ON wbcd.id = gdp."countryCode"
group by wbcd.region;





-- 5. Calculate percentage difference in value of GDP year-on-year per country.

-- 6. List 3 countries with lowest GDP per region.
-- Using Python I would run a for-loop over each region and search the wbcd data to return lowest 3 countries for GDP
-- SQL only allows While Loops
SELECT wbcd.name, wbcd.region, SUM(gdp."2019" + gdp."2020" + gdp."2021" + gdp."2022" + gdp."2023") as "total_gdp_growth"
FROM world_bank_country_data as wbcd
INNER JOIN gdp_data as gdp ON gdp."countryCode" = wbcd.id
WHERE gdp."2021" IS NOT NULL
  AND gdp."2022" IS NOT NULL
GROUP BY wbcd.name, wbcd.region
ORDER BY "total_gdp_growth";


-- 7. Provide an interesting fact from the dataset.
