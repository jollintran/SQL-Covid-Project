SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the Case Fatality Rate (CFR) of COVID in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as CFRPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows the prevalence of COVID
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PrevalencePercentage
FROM PortfolioProject..CovidDeaths
-- WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at country with highest infection rate compared to population
-- Shows country with the highest prevalence of COVID
SELECT  Location, population, MAX(total_cases) as HighestPrevelanceCount, MAX((total_cases/population))*100 as PrevalencePercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PrevalencePercentage desc

-- Showing the continent with the highest mortality rate due to COVID
SELECT  location, MAX(cast(total_deaths as int)) as HighestMortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location != 'World'
GROUP BY location
ORDER BY HighestMortalityRate desc

-- Showing the country with the highest mortality rate due to COVID
SELECT  Location, MAX(cast(total_deaths as int)) as HighestMortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY HighestMortalityRate desc

-- Showing 
SELECT  location, MAX(cast(total_deaths as int)) as HighestMortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY HighestMortalityRate desc

-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as WorldCaseFatalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
With PopulationvsVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentofVaccinations
FROM PopulationvsVaccination

-- TEMP TABLE

DROP TABLE if exists #PercentofVaccinations
CREATE TABLE #PercentofVaccinations
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentofVaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentofVaccinations
FROM #PercentofVaccinations

-- Creating view to store data for later visualizations

CREATE VIEW PercentofVaccinations as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

-- PercentofVaccinations as view
SELECT *
FROM PercentofVaccinations