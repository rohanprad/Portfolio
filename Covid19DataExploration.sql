/*

Exploring COVID-19 Data

*/

SELECT *
 FROM Covid19..Deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Selecting Data to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM	Covid19..Deaths
WHERE continent IS NOT NULL
ORDER BY location, date 

-- Mortality Rate (Chance of Dying) for All Countries

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS mortality_rate
FROM Covid19..Deaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Mortality Rate (Chance of Dying) in the United Kingdom

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS mortality_rate
FROM Covid19..Deaths
WHERE location LIKE '%Kingdom%'
AND continent IS NOT NULL
ORDER BY location, date

-- Infection Rate in the United Kingdom

SELECT location, date, population, total_cases, (total_cases/population)*100 as infection_rate
FROM Covid19..Deaths
WHERE location LIKE '%kingdom%'
ORDER BY location, date

-- Global Infection Rates

SELECT location, population, MAX(total_cases) AS latest_infection_count, MAX(total_cases/population)*100 AS latest_infection_rate
FROM Covid19..Deaths
GROUP BY location, population
ORDER BY latest_infection_rate DESC

-- Global Death Rates (By Country)

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS latest_death_count, MAX(CAST(total_deaths AS INT)/population)*100 AS latest_death_rate
FROM Covid19..Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY latest_death_count DESC

-- Global Death Rates (By Continent)
SELECT location, MAX(CAST(total_deaths AS INT)) AS latest_death_count, MAX(CAST(total_deaths AS INT)/population)*100 AS latest_death_rate
FROM Covid19..Deaths
WHERE continent IS NULL AND location <> 'International'
GROUP BY location
ORDER BY latest_death_count DESC

-- Daily Global Vaccination Rate (Atleast 1 dose)

-- Using CTE

WITH Daily_Count (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
AS
(
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, 
	SUM(CAST(vaccinations.new_vaccinations as INT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_vaccination_count
	FROM Covid19..Deaths deaths
	JOIN Covid19..Vaccinations vaccinations
		ON deaths.location = vaccinations.location
		AND deaths.date = vaccinations.date
	WHERE deaths.continent IS NOT NULL  
)
SELECT *, (rolling_vaccination_count/population)*100
FROM Daily_Count

-- Using Temp Table

DROP TABLE IF EXISTS Daily_Vaccination_Count
CREATE TABLE Daily_Vaccination_Count
(
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	rolling_vaccination_count NUMERIC
)

INSERT INTO Daily_Vaccination_Count
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, 
SUM(CAST(vaccinations.new_vaccinations as INT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_vaccination_count
FROM Covid19..Deaths deaths
JOIN Covid19..Vaccinations vaccinations
	ON deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL  

SELECT *, (rolling_vaccination_count/population)*100 AS daily_vaccination_rate
FROM Daily_Vaccination_Count

-- Creating a View

CREATE VIEW Daily_Vaccination_Count_View AS 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, 
SUM(CAST(vaccinations.new_vaccinations as INT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_vaccination_count
FROM Covid19..Deaths deaths
JOIN Covid19..Vaccinations vaccinations
	ON deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL 




