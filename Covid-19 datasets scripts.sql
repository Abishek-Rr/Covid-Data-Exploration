/*  
COVID-19  Data Exploration 

Skills used  :  Joins , Temp table , Windows function , Aggregate functions , Creating views , Converting Data types
 */


Select * from Portfolio..[COVID DEATH] where continent is not null order by 3,4;

--Select data that we are going to be starting with

Select location, date, population, total_cases, new_cases, total_deaths 
from Portfolio..[COVID DEATH]
where continent is not null
order by 1,2;

--LOOKING AT TOTAL CASES VS TOTAL DEATHS (of nepal ending with pal )

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from Portfolio..[COVID DEATH] 
where location like '%pal' 
and continent is not null  
order by 1,2;

--looking at Total_cases Vs population
--Shows what percentage of  population infected with Covid
select location , date, population, total_cases, (total_cases/population)*100 as Death_Percentage 
from Portfolio..[COVID DEATH] 
--where location like '%pal' 
order by 1,2;

--Looking at countries with highest Infection rate compared to population

select location, population,MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfect
from Portfolio..[COVID DEATH] 
--where location like '%pal' 
Group by location, population
order by PercentPopulationInfect desc;

--Showing countries with Highest Death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..[COVID DEATH]
--Where location like '%pal'
where continent is not null
Group by location
order by TotalDeathCount desc; 

--Showing continent with Highest Death count per Population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..[COVID DEATH]
--Where location like '%pal'
where continent is not null
Group by continent
order by TotalDeathCount desc; 

--Global Numbers (Total Cases , Total Deaths , Death Percentage )

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage 
from Portfolio..[COVID DEATH] 
--where location like '%pal' 
where continent is not null  
--Group by date
order by 1,2;


-- joining death and vaccinaton table
select * 
from Portfolio..[COVID vaccination] vac
join Portfolio..[COVID DEATH] dea
on dea.location = vac.location
and dea.date = vac.date

--Looking at Total Population Vs  Vaccinations

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..[COVID DEATH] dea
join Portfolio..[COVID vaccination] vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3;


 --Using CTE to perform calculation on partition by in previous query

 With popvsvac (continent, location, date , population , new_vaccinations , RollingPeopleVaccinated)
 as
 (
 select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolio..[COVID DEATH] dea
join Portfolio..[COVID vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *  , (RollingPeopleVaccinated/population)* 100
 from popvsvac


 -- Using Temp Table perform calculation on partition by in previous query

 create table #PercentofPeopleVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 insert into #PercentofPeopleVaccinated
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolio..[COVID DEATH] dea
join Portfolio..[COVID vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 select * , (RollingPeopleVaccinated/population)* 100
 from #PercentofPeopleVaccinated


 --Creating view to store Data for later visulizations
 create view PercentofPeopleVaccinated as
 select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolio..[COVID DEATH] dea
join Portfolio..[COVID vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null
 
