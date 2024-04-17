/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM ProjectPortfolio..CovidDeath
WHERE continent IS NOT NULL

SELECT *
FROM ProjectPortfolio..CovidVaccinations
WHERE continent IS NOT NULL

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio.dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Looking at Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100.0 AS deathPercentage 
FROM ProjectPortfolio.dbo.CovidDeath 
WHERE location LIKE '%india%'
ORDER BY location, date;



-- Looking at Total Cases vs Population
-- Shows what percent of population got covid
SELECT location, 
       date, 
       total_cases, 
       population, 
       (CONVERT(float, total_cases) / population) * 100.0 AS gotCovidPercentage 
FROM ProjectPortfolio.dbo.CovidDeath 
WHERE location LIKE '%india%'
ORDER BY location, date;



-- Looking at Countries with Highest Infection Rate comared to Population

SELECT location, 
       population, 
       MAX(total_cases) AS HighestInfectionCount,
	   MAX((CONVERT(float, total_cases) / population)) * 100.0 AS PercentPopulationInfected 
FROM ProjectPortfolio.dbo.CovidDeath 
--WHERE location LIKE '%india%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Showing Countries with Highest Death Count per Population

SELECT location, 
       MAX(CONVERT(INT,total_deaths)) AS TotalDeathCount
FROM ProjectPortfolio.dbo.CovidDeath 
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC




-- Let's Break Things Down BY Continent


-- Showing continents with the highest death count per population

SELECT continent, 
       MAX(CONVERT(INT,total_deaths)) AS TotalDeathCount
FROM ProjectPortfolio.dbo.CovidDeath 
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global Count

SELECT SUM(new_cases) AS total_cases, SUM(CONVERT(INT, new_deaths)) as total_deaths, (SUM(CONVERT(INT, new_deaths))/SUM(new_cases))*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Joing the tables

SELECT *
FROM ProjectPortfolio..CovidDeath DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date


-- Looking at Total Population VS Vaccinations

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CONVERT(INT, new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVacinated
FROM ProjectPortfolio..CovidDeath DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE

WITH poPvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent,
		DEA.location, 
		DEA.date, 
		DEA.population, 
		VAC.new_vaccinations, 
		SUM(CONVERT(INT, new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeath DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVaccinated
FROM poPvsVac


--USING TEMPTABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric(18, 2), -- Adjust the precision and scale as needed
	new_vaccinations numeric(18, 2), -- Adjust the precision and scale as needed
	RollingPeopleVaccinated numeric(18, 2) -- Adjust the precision and scale as needed
)
INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent,
		DEA.location, 
		DEA.date, 
		DEA.population, 
		VAC.new_vaccinations, 
		SUM(CONVERT(numeric(18, 2), VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeath DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT 
    *,
    (RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVaccinated
FROM 
    #PercentPopulationVaccinated;



-- Creating VIEW to store data for later visualitations

USE ProjectPortfolio

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent,
		DEA.location, 
		DEA.date, 
		DEA.population, 
		VAC.new_vaccinations, 
		SUM(CONVERT(numeric(18, 2), VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeath DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated