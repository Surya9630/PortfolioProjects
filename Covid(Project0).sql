

select * 
from project..CovidDeaths
where continent is not null
order by 3,4





--select * from project..CovidVaccinations
--order by 3,4



select location,date,total_cases,new_cases,total_deaths,population
 from project..CovidDeaths
 where continent is not null
 order by 1,2



 -- looking at total cases vs total deaths

 select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_precentage
 from project..CovidDeaths
 where location like '%INDIA%' and  continent is not null

 order by 1,2


 -- looking at total cases vs population
 --shows what percentage of population got covid

 select location,date,population,total_cases, (total_cases/population)*100 as popualtion_percentage
 from project..CovidDeaths
 where location like '%INDIA%' and  continent is not null

 order by 1,2





 -- lookin at countries with highest infection rate compared to populatoin

 select location,population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as Percentpopulationinfected
 from project..CovidDeaths
 --where location like '%INDIA%'
 where continent is not null
 group by location,population
 order by 4 desc




 --showing countries with highest death count per population

  select location,max(cast(total_deaths as int)) as totaldeathcount
 from project..CovidDeaths
 --where location like '%INDIA%'
 where continent is not null
 group by location
 order by 2 desc


--lets break things down by continet
-- showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount
 from project..CovidDeaths
 --where location like '%INDIA%'
 where continent is not null
 group by continent
 order by 2 desc
 

 -- global number

 select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
 from project..CovidDeaths
 --where location like '%INDIA%' and  continent is not null
 where continent is not null
 group by date
 order by 1,2


  select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
 from project..CovidDeaths
 --where location like '%INDIA%' and  continent is not null
 where continent is not null
 --group by date
 order by 1,2





 --looking at total population vs vaccination

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
 --,(rollingpeoplevaccinated/population)*100
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
      on dea.location= vac.location
	  and dea.date=vac.date
where dea.continent is not null
	  order by 2,3



--USE CTE

with PopvsVac (continent,location,date,population,new_vacinations,rollingpeoplevaccinated)
as 
(
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
 --,(rollingpeoplevaccinated/population)*100
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
      on dea.location= vac.location
	  and dea.date=vac.date
where dea.continent is not null
	 -- order by 2,3
)
select*,(rollingpeoplevaccinated/population)*100
from PopvsVac
















--TEMP TABLE
drop table if exists #PerecentPopulationVaccinated
create table #PerecentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO  #PerecentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
 --,(rollingpeoplevaccinated/population)*100
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
      on dea.location= vac.location
	  and dea.date=vac.date
--where dea.continent is not null
	 -- order by 2,3


select*,(rollingpeoplevaccinated/population)*100
from #PerecentPopulationVaccinated




--creating view to store datag for later visualizations


create view PercentPopulationVaccinated as 
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
 --,(rollingpeoplevaccinated/population)*100
 from project..CovidDeaths dea
 join project..CovidVaccinations vac
      on dea.location= vac.location
	  and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated