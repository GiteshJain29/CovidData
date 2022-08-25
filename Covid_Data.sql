USE PortfolioProject

SELECT location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'United States'
order by 1,2


-- looking at total cases vs pop.

SELECT location, date, total_cases, population, (total_cases / population)*100 as InfectionRate
from CovidDeaths
where location = 'United States'
order by 1,2

-- country with higest infection rate

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases / population))*100 as InfectionRate
from CovidDeaths
group by location, population
order by  InfectionRate desc

-- countries with highed deaths

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

-- continents with highest deaths

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location 
order by TotalDeathCount desc

-- global numbers 

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

-- total population vs vaccination

With Pop_vs_Vac(Continent, Location, Date, Population, New_Vaccinations, VaccinationsTillDate)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as VaccinationsTillDate
from CovidDeaths d
join CovidVaccinations v 
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select *, (vaccinationstilldate / population) * 100 as PercentageOfPopulationVaccinated
from Pop_vs_Vac
order by 2,3

Create View PopulationVaccinated as 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as VaccinationsTillDate
from CovidDeaths d
join CovidVaccinations v 
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

select * 
from PopulationVaccinated
order by 2,3