select *
from projectPortfolio..covid_deaths$
order by 3,4

--select *
--from projectPortfolio..covid_vaccination#excel$
--order by 3,4

--select data we are going to use

select location, date,total_cases,new_cases,total_deaths,population
from projectPortfolio..covid_deaths$
order by 1,2

--looking at total cases and total detahs

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from projectPortfolio..covid_deaths$
where location like '%India%'
order by 1,2

--looking at total_case vs the population

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from projectPortfolio..covid_deaths$
order by 1,2


select location,population,max(total_cases)as highestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from projectPortfolio..covid_deaths$
group by location,population
order by PercentPopulationInfected desc

  
  --showing countries with hghest death count per population

select location,max(cast(total_deaths as int))as TotalDeathCounts
from projectPortfolio..covid_deaths$
where continent is not null
group by location
order by TotalDeathCounts desc
 

 --by continent


select location,max(cast(total_deaths as int))as TotalDeathCounts
from projectPortfolio..covid_deaths$
where continent is null
group by location
order by TotalDeathCounts desc


--global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeaTHPercentage
from projectPortfolio..covid_deaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--TOTAL CASES
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeaTHPercentage
from projectPortfolio..covid_deaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--joining two tables

select *
from projectPortfolio..covid_deaths$ as dea
join projectPortfolio..covid_vaccination#excel$ as vac
on dea.location=vac.location
and dea.date=vac.date


--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from projectPortfolio..covid_deaths$ as dea
join projectPortfolio..covid_vaccination#excel$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with Popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from projectPortfolio..covid_deaths$ dea
join projectPortfolio..covid_vaccination#excel$  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from Popvsvac



--TEMP table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from projectPortfolio..covid_deaths$ dea
join projectPortfolio..covid_vaccination#excel$  vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating VIEW to store data for visualization
use projectPortfolio

CREATE VIEW PercentPopulationVaccinated
as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from projectPortfolio..covid_deaths$ dea
join projectPortfolio..covid_vaccination#excel$  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select * from PercentPopulationVaccinated
