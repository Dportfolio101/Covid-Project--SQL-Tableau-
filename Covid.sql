Select
	*
From
	[Covid.Project]..covid#death$

--Total Cases vs Population
--Show what percentage of the population contract Covid
Select
	date,
	location,
	population,
	total_cases,
	(total_cases/population)*100 AS percentage_of_population_infected
From
	[Covid.Project]..covid#death$
WHERE
	total_cases is NOT NULL --The Null value inhibit me from doing  arithmetic
Order BY
	date,
	location

--Countries with Highest Infection Rate
Select
	location,
	population,
	MAX (total_cases) AS Highest_Infection_Count,
	MAX ((total_cases/population))*100 AS Infection_rate
From
	[Covid.Project]..covid#death$
WHERE
	total_cases is NOT NULL --The Null value inhibit me from doing  arithmetic
GROUP BY
	location,
	population
Order BY
	Infection_rate desc

--Countries death count 
Select
	location,
	MAX(cast(total_deaths as int)) AS Total_Deaths_count
From
	[Covid.Project]..covid#death$
WHERE
	continent IS NOT NULL
GROUP BY
	location
Order BY
	Total_Deaths_count desc

Select
	location,
	MAX(cast(total_deaths as int)) AS Total_Deaths_count_By_Continent
From
	[Covid.Project]..covid#death$
WHERE
	continent IS NULL
GROUP BY
	location
Order BY
	2 desc

--Showing Contient with the highest death count per population
Select
	continent,
	MAX(cast(total_deaths as int)) AS Total_Deaths_count_By_Continent
From
	[Covid.Project]..covid#death$
WHERE
	continent IS NOT NULL
GROUP BY
	continent
Order BY
	2 desc

--Global Numbers
Select
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths as INT)) as total_deaths,
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
From
	[Covid.Project]..covid#death$
WHERE
	continent IS NOT NULL
ORDER BY
	1,
	2

--Joining both table
Select
	*
FROM 
	[Covid.Project]..covid#death$ dea
JOIN
	[Covid.Project]..covid#vaccination$ vac
ON
	dea.location = vac.location
	AND dea.date = vac.date

--Percent_OF_People_Vaccinated
Select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) AS RollingPeopleVaccinated
FROM 
	[Covid.Project]..covid#death$ dea
JOIN
	[Covid.Project]..covid#vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	2,
	3

--Creating tableau visual
Create View Percent_Population_vaccinated AS 
Select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) AS RollingPeopleVaccinated
FROM 
	[Covid.Project]..covid#death$ dea
JOIN
	[Covid.Project]..covid#vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

--Visual for DeathPercentage
Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From 
	[Covid.Project]..covid#death$
Where
	continent IS NOT NULL
order by 1,2


-- Visual for TotalDeathCount per Continent

Select 
	location, 
	SUM(cast(new_deaths as int)) as TotalDeathCount
From 
	[Covid.Project]..covid#death$
Where 
	continent IS NULL
	and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income') 
Group by 
	location
order by 
	TotalDeathCount desc

-- Visual for PercentPopulationInfected

Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as PercentPopulationInfected
From 
	[Covid.Project]..covid#death$
Group by 
	Location, Population
order by 
	PercentPopulationInfected desc


-- Visual for PercentPopulationInfected
Select
	Location,
	Population,
	date, 
	MAX(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as PercentPopulationInfected
From 
	[Covid.Project]..covid#death$
Group by 
	Location,
	Population,
	date
order by 
	PercentPopulationInfected desc

--Testing if View ran successfully
Select
	*
From
	Percent_Population_vaccinated