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