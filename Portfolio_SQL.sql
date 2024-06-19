select * from CovidDeaths

select * from CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths order by 1,2

-- Looking at Total Case vs Total Death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from CovidDeaths 
WHERE continent is not null
order by 1,2

-- Total cases vs Total Population

SELECT location, date, total_cases, population, (total_cases/population)*100 CasePercentage
from CovidDeaths 
where location like '%india'
order by 1,2

-- Looking at Countries with highest Infection rate compared to Population

SELECT location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
from CovidDeaths 
--where location like '%india'
GROUP BY location, population
order by 4 desc

-- Global Number

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
order by 2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER(partition by vac.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER(partition by vac.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 as Percentage_Vaccination
FROM PopVsVac


-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER(partition by vac.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated

-- Creating VIEW

CREATE VIEW PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER(partition by vac.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

