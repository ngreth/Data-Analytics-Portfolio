-- Select Data that we are using (source: https://ourworldindata.org/covid-deaths).

SELECT *
FROM PortfolioProjectNG..CovidVaccinations$
ORDER BY 3,4

-- Add a column for total cases.

SELECT Location, date, SUM (new_cases) OVER (ORDER BY date) as total_cases, new_cases, total_deaths, population
FROM PortfolioProjectNG..CovidDeaths$
ORDER BY 1,2

-- Let's compare the total number of cases to total number of deaths while focusing on the United States.

SELECT Location, date,  SUM (new_cases) OVER (ORDER BY date) as total_cases, total_deaths, (total_deaths/(SUM (new_cases) OVER (ORDER BY date)))*100 as death_percentage
FROM PortfolioProjectNG..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Assume the date that a new case is independent from the date that a new death is reported. 
-- If someone in the United States has an active case of COVID-19 on February 29, 2020, then they have a 2.08% chance of death. On March 25th, 2022, someone with an active case of COVID-19 has a 0.61% chance of death.

-- Let's compare the total number of deaths to the population for each country.

SELECT Location, MAX(cast(total_deaths as int)) AS total_deaths, Population, ((MAX(cast(total_deaths as int)))/Population)*100 as country_death_percentage
FROM PortfolioProjectNG..CovidDeaths$
WHERE continent is not null
GROUP BY Location, Population
ORDER BY 4 desc

-- We see that Peru has the highest percentage of deaths in the populatation attributed to COVID-19 as of 3/25/22 (0.64%).]

-- Now, let's join the CovidDeaths and CovidVaccinations databases to find more information.
-- In order to see the cumulative number of vaccinations each day for a given country, a partition function is used. Further, a CTE is used to check the percentage of people vaccinated each day for a given country.

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, cumulative_vaccinated)
AS
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as cumulative_vaccinated
FROM PortfolioProjectNG..CovidDeaths$ deaths
JOIN PortfolioProjectNG..CovidVaccinations$ vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
WHERE deaths.continent is not null
)
SELECT *, (cumulative_vaccinated/Population)*100 AS percent_vaccinated
FROM PopvsVac

-- Alternatively, a temp table can be used to accomplish the same task.

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as cumulative_vaccinated
FROM PortfolioProjectNG..CovidDeaths$ deaths
JOIN PortfolioProjectNG..CovidVaccinations$ vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
--WHERE deaths.continent is not null

SELECT *, (cumulative_vaccinations/Population)*100 AS percent_vaccinated
FROM #PercentPopulationVaccinated

-- Last, let's create a View to store data for visualizations.

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as cumulative_vaccinated
FROM PortfolioProjectNG..CovidDeaths$ deaths
JOIN PortfolioProjectNG..CovidVaccinations$ vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
WHERE deaths.continent is not null

SELECT * FROM PercentPopulationVaccinated

CREATE VIEW CASESVSDEATHSUS AS
SELECT Location, date,  SUM (new_cases) OVER (ORDER BY date) as total_cases, total_deaths, (total_deaths/(SUM (new_cases) OVER (ORDER BY date)))*100 as death_percentage
FROM PortfolioProjectNG..CovidDeaths$
WHERE location LIKE '%states%'
--ORDER BY 1,2

SELECT * FROM CASESVSDEATHSUS