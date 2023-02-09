/*
Covid 19 Data Exploration
*/


Select *
from [dbo].[CovidDeaths$]
Where continent is not null
order by 3, 4

--Select *
--from [dbo].[CovidVaccinations$]
--order by 3, 4

--Select Data needed

Select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths$]
Where continent is not null
Order by 1, 2


--Total Cases vs Total Deaths in Nigeria 

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths$]
Where location like '%nigeria%' and continent is not null
Order by 1, 2


--Percentage of Total Cases vs Population who got Covid

Select location, date, population, total_cases,(total_deaths/population)*100 as PercentPopulationInfected
from [dbo].[CovidDeaths$]
--Where location like '%nigeria%'
Order by 1, 2


--Countries with Highest Infection Rate compared to Population

Select location,population, Max(total_cases) as HighestInfectionCount, Max((total_deaths/population))*100 as PercentPopulationInfected
from [dbo].[CovidDeaths$]
--Where location like '%nigeria%'
Group by location, population
Order by PercentPopulationInfected Desc


--Countries with the Highest Death Count Per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths$]
--Where location like '%nigeria%'
Where continent is not null
Group by location
Order by TotalDeathCount Desc



-- BREAK THINGS DOWN BY CONTINENT 

--Continent with the Highest Death Count per Population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths$]
--Where location like '%nigeria%'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc



--GLOBAL NUMBERS

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths$]
--Where location like '%nigeria%' 
Where continent is not null
--Group by date
Order by 1, 2


-- Percentage Total Population vs Vaccinations that has receieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From[dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE to perform calculations on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From[dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using TEMP TABLE to perform calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From[dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From[dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null


