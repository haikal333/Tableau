SELECT *
From Sql..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--From Sql..CovidVaccinations
--Where continent is not null
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Sql..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contrat covid in your country
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Sql..CovidDeaths
Where location like '%malaysia%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, Population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Sql..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location, Population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From Sql..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Sql..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- show by continent


--Showing continent with highest death count per poppulation
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Sql..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- showing global numbers
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/  SUM(new_cases)*100 as DeathPercentage
From Sql..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccination
--USE CTE
With PopvsVac(Continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
From Sql..CovidDeaths dea
Join Sql..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated /Population)*100
From PopvsVac


--Temp Table
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
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
From Sql..CovidDeaths dea
Join Sql..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated /Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualisation
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
From Sql..CovidDeaths dea
Join Sql..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated

--hi
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Sql..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Sql..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Sql..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Sql..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc