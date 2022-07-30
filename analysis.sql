-- CREATE TABLE FOR COVID DEATHS
SELECT * FROM CovidDeaths
WHERE continent is not null
order by 3,4

CREATE TABLE CovidVax (
	iso_code VARCHAR,
	continent VARCHAR,
	locations VARCHAR,
	dates DATE,
	total_tests NUMERIC,
	new_tests NUMERIC,
	total_tests_per_thousand NUMERIC,
	new_tests_per_thousand NUMERIC,
	new_tests_smoothed NUMERIC,
	new_tests_smoothed_per_thousand NUMERIC,
	positive_rate NUMERIC,
	tests_per_case NUMERIC,
	tests_units VARCHAR,
	total_vaccinations NUMERIC,
	people_vaccinated NUMERIC,
	people_fully_vaccinated NUMERIC,
	total_boosters NUMERIC,
	new_vaccinations NUMERIC,
	new_vaccinations_smoothed NUMERIC,
	total_vaccinations_per_hundred NUMERIC,
	people_vaccinated_per_hundred NUMERIC,
	people_fully_vaccinated_per_hundred NUMERIC,
	total_boosters_per_hundred NUMERIC,
	new_vaccinations_smoothed_per_million NUMERIC,
	new_people_vaccinated_smoothed NUMERIC,
	new_people_vaccinated_smoothed_per_hundred NUMERIC,
	stringency_index NUMERIC,
	population_density NUMERIC,
	median_age NUMERIC,
	aged_65_older NUMERIC,
	aged_70_older NUMERIC,
	gdp_per_capita NUMERIC,
	extreme_poverty NUMERIC,
	cardiovasc_death_rate NUMERIC,
	diabetes_prevalence NUMERIC,
	female_smokers NUMERIC,
	male_smokers NUMERIC,
	handwashing_facilities NUMERIC,
	hospital_beds_per_thousand NUMERIC,
	life_expectancy NUMERIC,
	human_development_index NUMERIC,
	excess_mortality_cumulative_absolute NUMERIC,
	excess_mortality_cumulative NUMERIC,
	excess_mortality NUMERIC,
	excess_mortality_cumulative_per_million NUMERIC
);

-- SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
SELECT locations, dates, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- SHows likelihood of death by country in case of contracting virus
SELECT locations, dates, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE locations LIKE '%States'
Order by 1,2

-- Looking at total cases vs population
SELECT locations, dates, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM CovidDeaths
WHERE locations LIKE '%States'
Order by 1,2

-- What dates represented the highest infection rates? (US)
-- Dates where new cases were at their highest
SELECT locations, dates, new_cases, population, (new_cases/population)*100 AS NewCasesGrowing
FROM CovidDeaths
WHERE locations LIKE '%States'
Order by newcasesgrowing DESC

-- What countries have highest infection rate compared to population? 
-- Countries with highest infection rate compared to population
SELECT locations, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM CovidDeaths
--WHERE locations LIKE '%States'
GROUP BY locations, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest death count per population?
SELECT locations, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null and locations is not null
--WHERE locations LIKE '%States'
GROUP BY locations
ORDER BY TotalDeathCount DESC

-- Breaking down data by continent - highest death count by continent 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
--WHERE locations LIKE '%States'
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT * FROM coviddeaths;

SELECT locations, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
GROUP BY locations
ORDER BY TotalDeathCount DESC
-- Verified as accurate as of 7/29 -> particularly 6.4million total deaths :(

-- Global Numbers
SELECT dates, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage 
FROM coviddeaths
WHERE continent is not null and dates is not null
GROUP BY dates
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage 
FROM coviddeaths
WHERE continent is not null and dates is not null
--GROUP BY dates
order by 1,2

-- Covid Vaccination Data
SELECT * FROM covidvax;

SELECT *
FROM coviddeaths cd
JOIN covidvax cv
	ON cd.location = cv.location
	
-- Join tables on locations and dates
SELECT *
FROM coviddeaths as cd
INNER JOIN covidvax as cv
	ON cd.locations = cv.locations
	and cd.dates = cv.dates;
	
-- Example total population vs vaccinations
SELECT cd.continent, cd.locations, cd.dates, cd.population, cv.new_vaccinations
FROM coviddeaths as cd
INNER JOIN covidvax as cv
	ON cd.locations = cv.locations
	and cd.dates = cv.dates
WHERE cd.continent is not null --and cd.continent = 'North America'
ORDER BY 1,2,3

-- Look at vaccination broken up by location
SELECT cd.continent, cd.locations, cd.dates, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.locations ORDER BY cd.locations, cd.dates)
FROM coviddeaths as cd
INNER JOIN covidvax as cv
	ON cd.locations = cv.locations
	and cd.dates = cv.dates
WHERE cd.continent is not null and cd.continent = 'North America'
ORDER BY 1,2,3

-- Use CTE
WITH PopsvsVac (continent, locations, dates, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT cd.continent, cd.locations, cd.dates, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.locations ORDER BY cd.locations, cd.dates) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM coviddeaths as cd
INNER JOIN covidvax as cv
	ON cd.locations = cv.locations
	and cd.dates = cv.dates
WHERE cd.continent is not null and cd.continent = 'Europe'
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopsvsVac;


-- Temp Table #Percent Population Vaccinated
DROP Table if exists percentvax
CREATE TABLE percentvax (
	continent varchar,
	locations varchar,
	dates date,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert Into percentvax
SELECT cd.continent, cd.locations, cd.dates, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.locations ORDER BY cd.locations, cd.dates) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM coviddeaths as cd
INNER JOIN covidvax as cv
	ON cd.locations = cv.locations
	and cd.dates = cv.dates
--WHERE cd.continent is not null and cd.continent = 'Europe'
--ORDER BY 2,3

--US Numbers appear distorted for new_vax
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM percentvax
WHERE new_vaccinations is not null and locations = 'United States'

-- Storing view for later visualizations
Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.locations, cd.dates, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.locations ORDER BY cd.locations, cd.dates) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM coviddeaths as cd
INNER JOIN covidvax as cv
	ON cd.locations = cv.locations
	and cd.dates = cv.dates
WHERE cd.continent is not null

SELECT * FROM PercentPopulationVaccinated
