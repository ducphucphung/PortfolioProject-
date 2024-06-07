--looking at the total cases vs population
select location, date, population, total_cases, total_deaths, (total_deaths/population)*100 as DeathPercentage
from PortfolioPj..CovidDeaths
order by 1, 2

--looking at the country with the highest infection rate
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedRate
from PortfolioPj..CovidDeaths
group by location, population
order by PopulationInfectedRate desc

--showing the country with the highest death count per population
	select location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population))*100 as PopulationDeathRate
	from PortfolioPj..CovidDeaths
	where continent is not null
	group by location, population
	order by HighestDeathCount desc

--showing continent with the highest death count per population
--let's break things down by continent
select continent, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population))*100 as PopulationDeathRate
from PortfolioPj..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc


--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioPj..CovidDeaths
where continent is not null
--group by date
order by 1, 2


--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as TotalVaccinatedPeople
from PortfolioPj..CovidDeaths dea join PortfolioPj..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3

--Use CTE
With PopVsVac (continent, location, date, population, new_vaccinations, TotalVaccinatedPeople)
as 
(
select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as TotalVaccinatedPeople
from PortfolioPj..CovidDeaths dea join PortfolioPj..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 1, 2, 3
)    
select * , (TotalVaccinatedPeople/population)*100 as VaccinatedPercentage
from PopVsVac 

--TEMP TABLE
drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinatedPeople numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as TotalVaccinatedPeople
from PortfolioPj..CovidDeaths dea join PortfolioPj..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 1, 2, 3

select *, (TotalVaccinatedPeople/population)*100 as VaccinatedPercentage
from #PercentagePopulationVaccinated
order by 1, 2, 3

drop view if exists PercentagePopulationVaccinated
create view PercentagePopulationsVaccinated as
select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as TotalVaccinatedPeople
from PortfolioPj..CovidDeaths dea join PortfolioPj..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.location like '%vietnam%' 
--order by 1, 2, 3