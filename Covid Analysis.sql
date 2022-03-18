
Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

-- shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,
Convert(decimal(15,6), (Convert(Decimal(15,6), total_deaths) / Convert(Decimal(15,6), total_cases))*100) AS 'DeathPercentage'
From PortfolioProject..CovidDeaths$
Where continent is not null
--Where Location like '%brazil%'
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population got covid

Select Location, date, total_cases, population,
Convert(decimal(15,6), (Convert(Decimal(15,6), total_cases) / Convert(Decimal(15,6), population))*100) AS 'InfectedPercentage'
From PortfolioProject..CovidDeaths$
Where continent is not null
and Location like '%brazil%'
order by 1,2


-- looking at countries with highest infection rates compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount,
Convert(decimal(18,6), MAX(Convert(Decimal(18,6), total_cases) / Convert(Decimal(18,6), population))*100) AS PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries w/ the highest death count per population 

Select Location, MAX(cast(total_deaths as float)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathsCount desc


-- BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as float)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathsCount desc



-- GLOBAL NUMBERS

Select SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths,
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage

From PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
order by 1,2


-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float ,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVccinated 
--	, (RollingPeopleVccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float ,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated 
--	, (RollingPeopleVccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float ,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated 
--	, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	--Where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





--  CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float ,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated 
--	, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated