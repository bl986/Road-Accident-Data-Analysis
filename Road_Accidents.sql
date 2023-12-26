/*notes: to reopen this file and use directly in MS SQL server management studio (SSMS),
open SSMS first & connect, then drag this file in */

SELECT * FROM road_accident

SELECT SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
WHERE YEAR(accident_date) = '2022'

SELECT SUM(number_of_casualties) AS CY_Casualties_Surface_is_Dry
FROM road_accident
WHERE YEAR(accident_date) = '2022' AND road_surface_conditions = 'Dry'

/*CY_Accidents*/
SELECT COUNT(DISTINCT accident_index) AS CY_Accidents
FROM road_accident
WHERE YEAR(accident_date) = '2022'

/*CY_Fatal_Casualties*/
SELECT SUM(number_of_casualties) AS CY_Fatal_Casualties
FROM road_accident
WHERE YEAR(accident_date) = '2022' AND accident_severity = 'Fatal'

/*Fatal_Casualties (total of all years)*/
SELECT SUM(number_of_casualties) AS Fatal_Casualties
FROM road_accident
WHERE accident_severity = 'Fatal'

/*Serious_Casualties (total of all years)*/
SELECT SUM(number_of_casualties) AS Serious_Casualties
FROM road_accident
WHERE accident_severity = 'Serious'

/*CY_Serious_Casualties*/
SELECT SUM(number_of_casualties) AS CY_Serious_Casualties
FROM road_accident
WHERE YEAR(accident_date) = '2022' AND accident_severity = 'Serious'

/*CY_Slight_Casualties*/
SELECT SUM(number_of_casualties) AS CY_Slight_Casualties
FROM road_accident
WHERE YEAR(accident_date) = '2022' AND accident_severity = 'Slight'

/*Percentage of total (for slight casualties)*/
SELECT CAST(SUM(number_of_casualties) AS decimal(10,2)) *100 /
(SELECT CAST(SUM(number_of_casualties) AS decimal(10,2)) FROM road_accident)
AS Percentage_of_Total
FROM road_accident
WHERE accident_severity = 'Slight'

/*Percentage of total (for serious casualties)*/
SELECT CAST(SUM(number_of_casualties) AS decimal(10,2)) *100 /
(SELECT CAST(SUM(number_of_casualties) AS decimal(10,2)) FROM road_accident)
AS Percentage_of_Total
FROM road_accident
WHERE accident_severity = 'Serious'

/*Percentage of total (for fatal casualties)*/
SELECT CAST(SUM(number_of_casualties) AS decimal(10,2)) *100 /
(SELECT CAST(SUM(number_of_casualties) AS decimal(10,2)) FROM road_accident)
AS Percentage_of_Total
FROM road_accident
WHERE accident_severity = 'Fatal'


/*Casualties by Vehicle type (year of 2022)*/
SELECT 
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle 125cc and under', 'Motorcycle 50cc and under',
		'Motorcycle over 125cc and up to 500cc' , 'Motorcycle over 500cc' , 'Pedal cycle') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)',
		'Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over',
		'Goods over 3.5t. and under 7.5t', 'Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
		ELSE 'Other'
	END as vehicle_group,
	SUM(number_of_casualties) as CY_Casualties
	FROM road_accident
	--WHERE YEAR(accident_date) = '2022'
	GROUP BY
		CASE
			WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
			WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
			WHEN vehicle_type IN ('Motorcycle 125cc and under', 'Motorcycle 50cc and under',
			'Motorcycle over 125cc and up to 500cc' , 'Motorcycle over 500cc' , 'Pedal cycle') THEN 'Bike'
			WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)',
			'Minibus (8 - 16 passenger seats)') THEN 'Bus'
			WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over',
			'Goods over 3.5t. and under 7.5t', 'Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
			ELSE 'Other'
		END


--CY casualties vs PY casualties month by month
SELECT DATENAME(MONTH, accident_date) AS Month_Name , SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
WHERE YEAR(accident_date) = '2022'
GROUP BY DATENAME(MONTH, accident_date)

SELECT DATENAME(MONTH, accident_date) AS Month_Name , SUM(number_of_casualties) AS PY_Casualties
FROM road_accident
WHERE YEAR(accident_date) = '2021'
GROUP BY DATENAME(MONTH, accident_date)


--Casualties by road type
SELECT road_type, SUM(number_of_casualties) AS CY_Casualties FROM road_accident
WHERE YEAR(accident_date) = '2022'
GROUP BY road_type
--note: if using categorical value we need to group all the time!


--Casualties by Urban/Rural (percentage of total)
SELECT urban_or_rural_area, CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) *100/
(SELECT CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) FROM road_accident WHERE YEAR(accident_date) = '2022')
AS CY_casualties_Percentage_of_Total
FROM road_accident
WHERE YEAR(accident_date) = '2022'
GROUP BY urban_or_rural_area

SELECT urban_or_rural_area, SUM(number_of_casualties) AS Casualties_in_this_area,
CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) *100/
(SELECT CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) FROM road_accident)
AS Casualties_in_this_area_Percentage_of_Total
FROM road_accident
GROUP BY urban_or_rural_area


--Casualties by light condition
SELECT
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit',
		'Darkness - lights unlit', 'Darkness - no lighting') THEN 'Night'
		END AS Light_Condition,
		CAST(
			CAST(
				SUM(number_of_casualties) AS DECIMAL(10,2)) *100 / 
				(SELECT CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) FROM road_accident WHERE YEAR(accident_date) = '2022'
			)
			AS DECIMAL(10,2)
		)
		AS CY_Casualties_PercentageOfTotal
	FROM road_accident
	WHERE YEAR(accident_date) = '2022'
	GROUP BY
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit',
		'Darkness - lights unlit', 'Darkness - no lighting') THEN 'Night'
	END

--Top 10 locations by number of casualties
SELECT top 10 local_authority, SUM(number_of_casualties) AS Toal_Casualties_at_this_Location
FROM road_accident
GROUP BY local_authority
ORDER BY Toal_Casualties_at_this_Location DESC