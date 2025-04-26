select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, new_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at total deaths vs total cases
--Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, format(((total_deaths / total_cases) * 100), 'N5') as 'death_percentage'
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid
select location, date, population, total_cases, format(((total_cases / population) * 100), 'N5') as 'case_percentage'
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max(((total_cases / population) * 100)) as 'HighestInfectionRate'
from PortfolioProject..CovidDeaths
where continent is not null
group  by location, population
order by 4 desc


--Looking at the countries with highest death count per population
select location,  max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group  by location
--having max(total_deaths) is not null
order by 2 desc


--Looking at the countries with highest death rate per population
--select location, population, max(cast(total_deaths as int)) as HighestDeathCount, max(cast(((total_deaths / population) * 100) as float)) as 'HighestDeathRate'
--from PortfolioProject..CovidDeaths
--where continent is not null
--group  by location, population
--having max(total_deaths) is not null and max(((total_deaths / population) * 100)) is not null
--order by 4 desc


-- LETS BREAK THINGS DOWN BY CONTINENT

--Looking at the continent with highest death count per population
select continent,  max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group  by continent
having max(total_deaths) is not null
order by 2 desc


--Looking at the continent with highest death rate per population
--select location as Continent, population, max(cast(total_deaths as int)) as HighestDeathCount, max(cast(((total_deaths / population) * 100) as float)) as 'HighestDeathRate'
--from PortfolioProject..CovidDeaths
--where continent is null and location != 'World' and location != 'International' and location != 'European Union'
--group  by location, population
--having max(total_deaths) is not null and max(((total_deaths / population) * 100)) is not null
--order by 4 desc


--GLOBAL NUMBERS


select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, format(((sum(cast(new_deaths as int)) / sum(new_cases)) * 100), 'N5') as 'death_percentage'
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, format(((sum(cast(new_deaths as int)) / sum(new_cases)) * 100), 'N5') as 'death_percentage'
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2



--Looking at Total Population vs Vaccination

--WITH CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, population, new_vaccinations,
sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location =  vac.location and dea.date =  vac.date
where dea.continent is not null
--order by 2,3
)

select *, ((RollingPeopleVaccinated / Population) * 100) as PercentageVaccinated
from PopvsVac


--WITH TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, new_vaccinations,
sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location =  vac.location and dea.date =  vac.date
where dea.continent is not null
--order by 2,3

select *, ((RollingPeopleVaccinated / Population) * 100) as PercentageVaccinated
from #PercentPopulationVaccinated


--Creating view to store data in later visualizations
drop view PercentPopulationVaccinated
go
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location =  vac.location 
	and dea.date =  vac.date
where dea.continent is not null
--order by 2,3


select *
from  PercentPopulationVaccinated