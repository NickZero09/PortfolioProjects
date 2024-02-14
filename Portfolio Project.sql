Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null 
-- El Where lo utilizamos por que en la tabla tenemos los casos por paises pero además en esa misma columna aparecen continentes que no deberían estar (y lo vamos a colocar en cada parte debido a que no nos interesa esa información adicional)
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in tour country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentege of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where continent is not null 
--Where location like '%Chile%'
order by 1,2


-- Looking at Countries with Highets Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where continent is not null 
--Where location like '%Chile%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null 
--Where location like '%Chile%'
Group by Location
order by TotalDeathCount desc

-- LET's BREAK THING DOWN BY CONTINENT (Aqui nos damos cuenta de algunos errores que hay por ejemplo North America está contando solo a EEUU)
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null 
--Where location like '%Chile%'
Group by continent
order by TotalDeathCount desc

-- Con esto podemos ver los reales valores (Porblemas a enfrentar en el dia a dia)
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null 
--Where location like '%Chile%'
Group by location
order by TotalDeathCount desc

-- En el curso vamos a utilizar la información directa que nos proporciona la tabla con "continent"
-- Showing continetns with the hightest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null 
--Where location like '%Chile%'
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- Es imporante ver el tipo de dato de cada variable (vnarchar, float, etc)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 
--Where location like '%states%'
-- Group by date
Order by 1,2


-- Looking at Total Population vs Vaccionations
-- Vamos a unir las dos tablas
-- Obtenemos una columna con la frecuencia acumulada
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccionated/population)*100
From [Portfolio Project]..CovidDeaths dea   -- dea y vac son nombre que les pusimos a las tablas para ahorrar texto
join [Portfolio Project]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccionated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccionated/population)*100
From [Portfolio Project]..CovidDeaths dea   -- dea y vac son nombre que les pusimos a las tablas para ahorrar texto
join [Portfolio Project]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccionated/Population)*100
From PopvsVac

-- Podemos decir de la fila 863 que el 12% de la población de Algeniaestá vacunada


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccionated numeric
)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccionated/population)*100
From [Portfolio Project]..CovidDeaths dea   -- dea y vac son nombre que les pusimos a las tablas para ahorrar texto
join [Portfolio Project]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3


Select *, (RollingPeopleVaccionated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccionated/population)*100
From [Portfolio Project]..CovidDeaths dea   -- dea y vac son nombre que les pusimos a las tablas para ahorrar texto
join [Portfolio Project]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated