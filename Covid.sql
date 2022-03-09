select *
from Covid..CovidDeaths
where continent is not null
order by 3,4


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid..CovidDeaths
where location like '%India%'
order by 1,2


--total cases vs population

select location, date, total_cases, population,  (total_cases/population)*100 as CovidPercentage
from Covid..CovidDeaths
where location like '%india%'


--highest infection rate

select location, population,max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as PercentPopulationInfected
from Covid..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--countries with highest death count
 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Covid..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


--continents with highest death count 

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc 


--global numbers

select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from Covid..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from Covid..CovidDeaths
where continent is not null
order by 1,2

select *
from Covid..CovidVaccinations


--total population vs vaccination

select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(V.new_vaccinations) over (partition by D.location order by D.location, D.date) as RollingPeopleVaccinated
from Covid..CovidDeaths D
join Covid..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 2,3


--use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(V.new_vaccinations) over (partition by D.location order by D.location, D.date) as RollingPeopleVaccinated
from Covid..CovidDeaths D
join Covid..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from popvsvac


--temp table

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into PercentPopulationVaccinated
select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(V.new_vaccinations) over (partition by D.location order by D.location, D.date) as RollingPeopleVaccinated
from Covid..CovidDeaths D
join Covid..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from PercentPopulationVaccinated


--create view to store data

create view PercentPopulationVaccinatedView as
select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(V.new_vaccinations) over (partition by D.location order by D.location, D.date) as RollingPeopleVaccinated
from Covid..CovidDeaths D
join Covid..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null


select *
from PercentPopulationVaccinatedView