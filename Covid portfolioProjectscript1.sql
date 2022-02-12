--selecting the data i need

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--looking at the total cases vs total deaths


SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%nigeria%'
and continent is not null
ORDER BY 1,2


--looking at Total cases vs Population
--shows what percentage of population was infected

SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentInfected
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%nigeria%'
ORDER BY 1,2

--looking at country with highest infection rate with respect to the population

SELECT location, population, MAX(total_cases), MAX((total_cases/population))*100 as maxPopulationPercentInfected
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%nigeria%'
GROUP BY location,population
ORDER BY maxPopulationPercentInfected DESC

--Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAKING IT DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers
SELECT location,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location
WHERE continent is not null
ORDER BY 1,2

--to check total cases

SELECT date, SUM(new_cases)as SUM_Cases, SUM(cast(new_deaths as int)) as SUM_NewDeath, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases)as SUM_Cases, SUM(cast(new_deaths as int)) as SUM_NewDeath, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at the Total population versus the vaccination

SELECT *
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac 
ON dea.location = vac.location
AND dea.date = vac.date


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--and new_vaccinations is not null
ORDER BY 2,3




SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,new_cases ,new_deaths
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--and new_vaccinations is not null
ORDER BY 2,3

--Total Population vs Vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as cummulative_new_vac
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Percentage of populaton vaccinated
--use CTE

WITH PopvsVac (continent,location,date,population,new_vaccinations,cummulative_new_vac)
AS(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as cummulative_new_vac
--,(cummulative_new_vac/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (cummulative_new_vac/population)*100 as percentPopVac
FROM PopvsVac

--using Temp table
DROP Table if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
populations numeric,
new_vaccinations numeric,
cummulative_new_vac numeric
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as numeric)) OVER (Partition by dea.location order by dea.location,dea.Date) as cummulative_new_vac
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac 
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(cummulative_new_vac/populations)*100 as percentPopVacc
FROM #percentpopulationvaccinated


--Create view to store data for visualisation later

CREATE VIEW percentpopulatonvaccinated 
as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as numeric)) OVER (Partition by dea.location order by dea.location,dea.Date) as cummulative_new_vac
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccination vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
from percentpopulatonvaccinated