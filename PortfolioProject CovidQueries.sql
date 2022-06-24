SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

-- SELECT Data from CovidDeaths that going to be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Basic calculations on Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in China - 5.4% the highest in April 2020
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE Location like '%hina' AND continent is not null
ORDER BY 5 DESC

-- Looking at Total Cases vs Population
-- Shows that percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
FROM CovidDeaths
WHERE Location like '%hina' and continent is not null
ORDER BY 1,2

-- Figure out countries has the highest Infection Rate compared to Population
-- Shocking there's a country with 70% of population infected :(
SELECT Location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases)/population)*100 PercentPopulationInfected
FROM CovidDeaths
--WHERE Location like '%hina'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Desth per population
-- There's an issue with the data type for Total_Deaths, gotta convert to int to COUNT
SELECT Location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
WHERE Location like '%anada' 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- There are grouping continents in location data like South America, World etc --> figure out the issue: the location appears to be the continent where the continent is null.
-- Adding an syntax statement: WHERE continent is not null

-- BREAKING THINSG DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
--WHERE Location like '%hina'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
--WHERE Location like '%hina'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

-- GLOBAL numbers daily
SELECT date, SUM(total_cases) totalcase, SUM(cast(new_deaths as int)) dailynewdeath, SUM(cast(new_deaths as int))/SUM(total_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- across the world
SELECT SUM(total_cases) totalcase, SUM(cast(new_deaths as int)) dailynewdeath, SUM(cast(new_deaths as int))/SUM(total_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- JOIN Deaths table and Vaccination table
-- Looking at total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Createing CTE
-- TO_DATE vaccinated population out of the location
With POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM POPvsVAC

-- Temptable

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated




