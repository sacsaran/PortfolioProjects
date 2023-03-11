

select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by 3,4


select * 
from PortfolioProject.dbo.CovidVaccinations
order by 3,4

--select  data we will be using
select location, total_cases, new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total death

--Shows Likelyhood of dying by covid if you have covid in your country
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as PercentageDeath
from PortfolioProject.dbo.CovidDeaths
where location like'%United kingdom%' and continent is not null

order by 1,2

--Population vs total cases
--Displying the percentage of population that had covid

select location, date, population,total_cases,(total_cases/population)*100 as PercentageInfected
from PortfolioProject.dbo.CovidDeaths
--where location like'%United states%'
order by 1,2

--Country with the highest infection rate compare to their population
select location, population,max(total_cases) as HighestInfectionCount,(max(total_cases)/population)*100 as PercentageInfected
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by PercentageInfected desc

--showing the country with the highest death count per population
select location, max(cast (total_deaths as int)) as totalDeathCountcount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by totalDeathCountCount desc

--showing the continent with the highest death rate
select continent, max(cast (total_deaths as int)) as totalDeathCountCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by totalDeathCountCount desc


--showing the continent with the highest death count
select continent, max(cast(total_deaths as int )) as highestCount
from CovidDeaths
where continent is not null
group by continent 
order by highestCount desc

--Global Numbers
select date ,sum(new_cases) as Global_newCases, sum(cast(new_deaths as int )) as Global_newDeath, (sum(cast(new_deaths as int ))/ sum(new_cases))  *100 as DeathPercemtage
from CovidDeaths
where continent is not null 
group by date
order by 1,2

--showing the total New cases and death cases in the world
select sum(new_cases) as TotalCasesGlobaly, sum(convert(int, new_deaths)) as TotalDeathGlobaly, (sum(cast(new_deaths as int ))/ sum(new_cases))  *100 as DeathPercemtage
from CovidDeaths
where continent is not null 
--group by date
order by 1,2


-- showing the second table(vaccicnation) and 

--looking at at the Total population vs vaccination

select death.continent, death.location, death.date, death.population, vac.new_vaccinations as new_vaccinations_PerDay
 from PortfolioProject.dbo.CovidDeaths as death join 
 PortfolioProject.dbo.CovidVaccinations as vac on 
death.location = vac.location and death.date= Vac.date
where death.continent is not null
order by 2,3

-- using partition by to do the sum of all the new vaccication by a location
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as RollingPeoepleVaccinated 
 from PortfolioProject.dbo.CovidDeaths as death join 
 PortfolioProject.dbo.CovidVaccinations as vac on 
death.location = vac.location and death.date= Vac.date
where death.continent is not null
order by 2,3

-- showing how many people got vaccinated by country(location) by dividing the RollingPeoepleVaccinated/ population 
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by death.location order by death.location,
death.date) as RollingPeoepleVaccinated
--(RollingPeoepleVaccinated/ population)*100
 from PortfolioProject.dbo.CovidDeaths as death join 
 PortfolioProject.dbo.CovidVaccinations as vac on 
death.location = vac.location and death.date= Vac.date
where death.continent is not null
order by 2,3

--using the CTE to solve the above problem

with PopulationVSVAcc (continent, location, date, population, new_vaccinations,RollingPeoepleVaccinated) 
as 
(select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by death.location order by death.location,
death.date) as RollingPeoepleVaccinated
--(RollingPeoepleVaccinated/ population)*100
 from PortfolioProject.dbo.CovidDeaths as death join 
 PortfolioProject.dbo.CovidVaccinations as vac on 
death.location = vac.location and death.date= Vac.date
where death.continent is not null
--order by 2,3
)

select * ,(RollingPeoepleVaccinated/population)*100
from  PopulationVSVAcc

--Temp table
drop table if exists #PercentTableVacinated
create table #PercentTableVacinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeoepleVaccinated numeric)


insert into #PercentTableVacinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by death.location order by death.location,
death.date) as RollingPeoepleVaccinated
--(RollingPeoepleVaccinated/ population)*100
 from PortfolioProject.dbo.CovidDeaths as death join 
 PortfolioProject.dbo.CovidVaccinations as vac on 
death.location = vac.location and death.date= Vac.date
where death.continent is not null

select * ,(RollingPeoepleVaccinated/population)*100
from  #PercentTableVacinated

-- creating view to use to use for futher visualisaion on tableau or power BI
--showing the continent with the highest death count

create view Highest_COvid_Death as 
select continent, max(cast(total_deaths as int )) as highestCount
from CovidDeaths
where continent is not null
group by continent 
--order by highestCount desc

create view PercentTableVacinated as 

select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by death.location order by death.location,
death.date) as RollingPeoepleVaccinated
--(RollingPeoepleVaccinated/ population)*100
 from PortfolioProject.dbo.CovidDeaths as death join 
 PortfolioProject.dbo.CovidVaccinations as vac on 
death.location = vac.location and death.date= Vac.date
where death.continent is not null
--order by 2,3


select * from PercentTableVacinated



