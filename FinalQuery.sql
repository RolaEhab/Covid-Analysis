
-- Death Precentage in Countries
--Viewing the Death Precentages overtime 
-- Shows the likelihood of dying if you contract covid in your country, you can filter it by country

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortofoilioProjects..CovidDeaths
--WHERE location LIKE '%Egypt%'
--AND continent IS NOT NULL
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Infection Precentage
-- Looking at the total cases VS population
-- Shows the probability of getting infected with covid troughout countries

SELECT location, date, population, total_cases, (CONVERT(float,total_cases)/ NULLIF(CONVERT(float, population), 0))*100 AS InfectionPrecentage
FROM PortofoilioProjects..CovidDeaths
--where location LIKE '%Egypt%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Highest infection Precentage
-- Looking at countries with highest infection rate compared to population
-- Locations with the highest Infection Precentage Descendingly
SELECT location, population, MAX(total_cases) AS HighestCasesCount, MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))*100 AS HighestInfectionPrecentages
FROM PortofoilioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY  HighestInfectionPrecentages desc


--Total Deaths from covid by continent
--Showing Total death counts by continent 
--There is an inconsistency in the data that location somtimes is the whole continent and the continent is null so the data is repeated
SELECT location, MAX(CONVERT(float,total_deaths)) AS TotalDeathCount
FROM PortofoilioProjects..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc
--FOR VISUALIZATION
SELECT continent, MAX(CONVERT(float, total_deaths)) AS TotalDeaths
FROM PortofoilioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths desc


-- GLOBALLY

--Shows death precentage EACH DAY in all the world

SELECT date, SUM(CONVERT(int, new_cases)) AS total_cases, SUM(CONVERT(int, new_deaths)) AS total_deaths, (SUM(CONVERT(int, new_deaths))/ NULLIF(SUM(CONVERT(float, total_cases)),0))*100 AS DeathPrecentage
FROM PortofoilioProjects..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date

-- Shows death Precentage From Covid in the whole world
SELECT SUM(CONVERT(int, new_cases)) AS total_cases, SUM(CONVERT(int, new_deaths)) AS total_deaths, (SUM(CONVERT(int, new_deaths))/ NULLIF(SUM(CONVERT(float, total_cases)),0))*100 AS DeathPrecentage
FROM PortofoilioProjects..CovidDeaths
WHERE continent is not null


-- USING CTE
With PopulationVSVacc (Continent, Location, Date, Population, NewVaccinations, RollingVaccinationsCount)
as(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(Convert(int,vacc.new_vaccinations)) Over (Partition by death.location Order by death.date) as Total_Vaccinations
From PortofoilioProjects..CovidDeaths as death
Join PortofoilioProjects..CovidVaccinations as vacc
ON death.location = vacc.location 
and death.date = vacc.date
Where death.continent is not null
--Order by death.location ,death.date
)
Select * , (RollingVaccinationsCount / Convert(float,Population)) * 100 as PopVsVacPrecentage
From PopulationVSVacc




-- Creating TEMP tables
Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationsCount numeric
)
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(Convert(int,vacc.new_vaccinations)) Over (Partition by death.location Order by death.date) as RollingVaccinationsCount
From PortofoilioProjects..CovidDeaths as death
Join PortofoilioProjects..CovidVaccinations as vacc
ON death.location = vacc.location 
and death.date = vacc.date
Where death.continent is not null

Select * , (RollingVaccinationsCount / Convert(float,Population)) * 100 as PopVsVacPrecentage
From #PercentPopulationVaccinated
Order by Location ,Date

