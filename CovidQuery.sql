-- Select Data we are using

SELECT location, date, total_cases, CAST(new_cases AS FLOAT), total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'New Zealand'
ORDER BY 1,2

-- Total cases vs population
SELECT location, date, total_cases, population, (total_cases / population)*100 AS case_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'New Zealand'
ORDER BY 1,2


-- which countries have highest infection rates
SELECT location, MAX(total_cases) AS highest_total_cases , population, (MAX(total_cases) / population)*100 AS case_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY case_percentage DESC

SELECT location, date, MAX(total_cases) AS highest_total_cases , population, (MAX(total_cases) / population)*100 AS case_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population, date
ORDER BY case_percentage DESC

-- Countries with highest mortality rate
SELECT location, MAX(total_deaths) AS highest_total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY Location
ORDER BY highest_total_deaths DESC


SELECT continent, SUM(max_deaths) AS total_continent_deaths
FROM (SELECT location,  continent, MAX(total_deaths) AS max_deaths
	  FROM PortfolioProject..CovidDeaths
	  WHERE continent IS NOT null
	  GROUP BY location, continent)AS Q1
GROUP BY continent
ORDER BY total_continent_deaths DESC

SELECT location, MAX(total_deaths) AS highest_total_deaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'Europe'
OR location = 'North America'
OR location = 'South America'
OR location = 'Asia'
OR location = 'Oceania'
OR location = 'Africa'
GROUP BY Location
ORDER BY highest_total_deaths DESC

-- Global Numbers
SELECT date, sum(CAST(new_cases AS FLOAT)) AS total_new_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_new_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 AS total_death_proportion
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT sum(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 AS total_death_proportion
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--  Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.location, dea.date, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1


-- CTE

WITH vac_proportion (location, date, population, new_vaccintaions, sum_of_vaccinations)
AS
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_vaccinations
--(sum_of_vaccinations/dea.population) * 100 AS vaccintation_proportion
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (sum_of_vaccinations/population) * 100 AS proportion_of_vaccinations
FROM vac_proportion
ORDER BY location

CREATE VIEW vaccination_view AS
WITH vac_proportion (location, date, population, new_vaccintaions, sum_of_vaccinations)
AS
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (sum_of_vaccinations/population) * 100 AS proportion_of_vaccinations
FROM vac_proportion

SELECT * FROM vaccination_view