SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data to use for the project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentageIre
FROM PortfolioProject..CovidDeaths
WHERE location like '%Ireland%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population, it shows the percentage of the population that has contracted COVID

SELECT location, date, population, total_cases, (total_cases/population)* 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%Ireland%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
--What percentage of the population has COVID
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Ireland%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


--Showing Countries with Highest Deaths count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking the data down by Continent 

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing Continent with Highest Deaths count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_death, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Ireland%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Global Cases, Deaths and Death percentage

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_death, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Ireland%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population) * 100
--,SUM(CONVERT(int,vac.new_vaccinations AS int)) over (Partition By dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	--and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3


--Use CTE (Common Table Expressions)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(BIGINT,vac.new_vaccinations)) over (Partition By dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--,SUM(CONVERT(int,vac.new_vaccinations AS int)) over (Partition By dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	--and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT * ,(RollingPeopleVaccinated/Population) * 100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition BY dea.Location ORDER BY dea.location,
 dea.Date) AS RollingPeopleVaccinated
--,SUM(CONVERT(int,vac.new_vaccinations AS int)) over (Partition By dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	--and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

--DROP TABLE #PercentPopulationVaccinated



-- fROM gIThUB

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
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	--and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

 


-- Creating View to store data for visualisation

CREATE VIEW DeathPercentageIre AS 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentageIre
FROM PortfolioProject..CovidDeaths
WHERE location like '%Ireland%'
AND continent IS NOT NULL
--ORDER BY 1,2

SELECT *
FROM DeathPercentageIre


CREATE VIEW PercentagePopulationInfected AS
SELECT location, date, population, total_cases, (total_cases/population)* 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%Ireland%'
AND continent IS NOT NULL
--ORDER BY 1,2

SELECT *
FROM PercentagePopulationInfected
--ORDER BY 1,2


CREATE VIEW HighestInfectionGlobal AS
--Looking at Countries with Highest Infection Rate compared to Population
--What percentage of the population has COVID
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Ireland%'
GROUP BY location, population
--ORDER BY PercentagePopulationInfected DESC


SELECT *
FROM HighestInfectionGlobal
ORDER BY PercentagePopulationInfected DESC



CREATE VIEW PopulationVSVaccinations AS
-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(BIGINT,vac.new_vaccinations)) over (Partition By dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population) * 100
--,SUM(CONVERT(int,vac.new_vaccinations AS int)) over (Partition By dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	--and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PopulationVSVaccinations

--DROP VIEW PopulationVSVaccinations




