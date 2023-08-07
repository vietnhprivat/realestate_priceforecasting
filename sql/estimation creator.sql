SELECT year, COUNT(*) AS row_count
FROM estimated_powerplant_data
GROUP BY year;

select * from estimated_powerplant_data;

SELECT primary_fuel, SUM(estimated_generation) AS total_capacity
FROM estimated_powerplant_data
GROUP BY primary_fuel
ORDER BY total_capacity DESC;

select country_long, primary_fuel, sum(capacity_in_MW), sum(estimated_generation_gwh_2021)
from powerplants_data
group by country_long, primary_fuel;



-- Step 1: Create the new table with the "year" column set to 2021.
CREATE TABLE estimated_powerplant_data AS
SELECT country_long, primary_fuel, sum(capacity_in_MW) as capacity, sum(estimated_generation_gwh_2021) as estimated_generation, 2021 as year
FROM powerplants_data
GROUP BY country_long, primary_fuel;

-- Step 2: Insert new rows for the years 2022 to 2031.
INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2022 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2023 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2024 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2025 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2026 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2027 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2028 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2029 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2030 as year
FROM estimated_powerplant_data
WHERE year = 2021;

INSERT INTO estimated_powerplant_data (country_long, primary_fuel, capacity, year)
SELECT country_long, primary_fuel, capacity, 2031 as year
FROM estimated_powerplant_data
WHERE year = 2021;


-- New column t
ALTER TABLE estimated_powerplant_data ADD COLUMN t INT;

-- Set right t values
UPDATE estimated_powerplant_data
SET t = CASE
    WHEN year = 2021 THEN 1
    WHEN year = 2022 THEN 2
    WHEN year = 2023 THEN 3
    WHEN year = 2024 THEN 4
    WHEN year = 2025 THEN 5
    WHEN year = 2026 THEN 6
    WHEN year = 2027 THEN 7
    WHEN year = 2028 THEN 8
    WHEN year = 2029 THEN 9
    WHEN year = 2030 THEN 10
    WHEN year = 2031 THEN 11
END;


SELECT *
FROM estimated_powerplant_data
INTO OUTFILE 'C:/Users/viet-intel/orsted_projekt/data/output/output.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SHOW VARIABLES LIKE "secure_file_priv";


