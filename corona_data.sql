SELECT * FROM corona_data;
-- SELECT CONVERT(Date, GETDATE()) from corona_data;
-- Data Cleaning
-- Q1 Check for NULL values and Update nulls with zeros for all columns
SELECT * 
	FROM corona_data
	WHERE Province IS NULL
	OR Country_Region IS NULL 
	OR Latitude IS NULL
	OR Longitude IS NULL
	OR Date IS NULL
	OR Confirmed IS NULL
	OR Deaths IS NULL
	OR Recovered IS NULL;

-- Q2 Check for total number of rows
SELECT COUNT(*) AS num_of_rows
	FROM corona_data;

-- Q3 Check start date and end date
SELECT 
	CONVERT(Date, MIN(Date)) AS start_date,
	CONVERT(Date, MAX(Date)) AS end_date
	FROM corona_data;

-- Q4 Number of months in the dataset
SELECT COUNT(DISTINCT FORMAT(Date, 'yyyy-MM')) AS MONTHS
FROM corona_data;

-- Q5 Find monthly average for confirmed deaths, recovered
SELECT FORMAT(Date, 'yyyy-MM') AS MONTHS,
	ROUND(AVG(CAST(Confirmed AS float)),2) avg_confirmed,
	ROUND(AVG(CAST(Deaths AS FLOAT)),2) avg_deaths,
	ROUND(AVG(CAST(Recovered AS FLOAT)),2) avg_recovered
	FROM corona_data
	GROUP BY FORMAT(Date, 'yyyy-MM')
	ORDER BY MONTHS;

-- Q5 Find minimum values for confirmed, deaths, recovered per year
SELECT FORMAT(Date, 'yyyy') AS Yr,
	MIN(CAST(Confirmed AS float)) min_confirmed,
	MIN(CAST(Deaths AS FLOAT)) min_deaths,
	MIN(CAST(Recovered AS FLOAT)) min_recovered
	FROM corona_data
	WHERE Confirmed != 0 AND Deaths != 0 AND Recovered != 0
	GROUP BY FORMAT(Date, 'yyyy')
	ORDER BY Yr;

-- Q6 Find minimum values for confirmed, deaths, recovered per year
SELECT FORMAT(Date, 'yyyy') AS Yr,
	MAX(CAST(Confirmed AS float)) max_confirmed,
	MAX(CAST(Deaths AS FLOAT)) max_deaths,
	MAX(CAST(Recovered AS FLOAT)) max_recovered
	FROM corona_data
	WHERE Confirmed != 0 AND Deaths != 0 AND Recovered != 0
	GROUP BY FORMAT(Date, 'yyyy')
	ORDER BY Yr;

-- Q7 The total number of cases confirmed, deaths, recovered per month
SELECT FORMAT(Date, 'yyyy-MM') AS MONTHS,
	SUM(CAST(Confirmed AS float)) total_confirmed,
	SUM(CAST(Deaths AS FLOAT)) total_deaths,
	SUM(CAST(Recovered AS FLOAT)) total_recovered
	FROM corona_data
	GROUP BY FORMAT(Date, 'yyyy-MM')
	ORDER BY MONTHS;

-- Q7 The total number of cases confirmed, deaths, recovered per Year
SELECT 
    FORMAT(Date, 'yyyy') AS Year,
    SUM(CAST(Confirmed AS FLOAT)) AS total_confirmed,
    SUM(CAST(Deaths AS FLOAT)) AS total_deaths,
    SUM(CAST(Recovered AS FLOAT)) AS total_recovered
FROM corona_data
GROUP BY FORMAT(Date, 'yyyy')
ORDER BY Year;


-- Q8 Find top 5 countries having thw highest number of confirmed case
SELECT Country_Region,
	SUM(CAST(Confirmed AS FLOAT)) total_confirmed
	FROM corona_data
	GROUP BY Country_Region
	ORDER BY 2 DESC;

	-- Solution 2
	WITH totalConfirmed AS (
	SELECT Country_Region,
	SUM(CAST(Confirmed AS FLOAT)) total_confirmed
	FROM corona_data
	GROUP BY Country_Region),
	TotalConfirmedRank AS (
	SELECT *,
	RANK() OVER(ORDER BY total_confirmed DESC) AS ranking FROM totalConfirmed)
	SELECT Country_Region 
	FROM TotalConfirmedRank 
	WHERE ranking =1;

-- Q9 Case Fatality Rate Calculate the CFR for each country 
SELECT DISTINCT Country_Region,
	ROUND(
        (SUM(CAST(Deaths AS FLOAT)) / SUM(CAST(Confirmed AS FLOAT))) * 100, 
        2
    ) AS CFR_RATE
	FROM corona_data
	GROUP BY Country_Region
	ORDER BY CFR_RATE DESC;

-- 10.	Growth rate: Calculate the daily or monthly growth rates of confirmed cases to identify periods of rapid spread
WITH monthlycases AS (
	SELECT 
		FORMAT(Date, 'yyyy-MM') AS Months,
		SUM(CAST(Confirmed AS FLOAT)) AS Total_confirmed
	FROM corona_data
	GROUP BY FORMAT(Date, 'yyyy-MM')
	), 
	GrowthRate AS (
	SELECT 
		Months,
		Total_confirmed,
		LAG(Total_confirmed) OVER (ORDER BY Months) AS previous_month
	FROM monthlycases
	)
	SELECT 
		Months,
		Total_confirmed,
		previous_month,
		ROUND(((Total_confirmed - previous_month)/previous_month) * 100, 2) AS Growth_rate_Percentage
	FROM GrowthRate
	WHERE previous_month IS NOT NULL
	ORDER BY Months;
