-- Databricks notebook source
--LOADING DATASET
USE brighttv.data;

SELECT*
FROM brighttv.data.user_profiles;---inspecting first tables contents

SELECT *
FROM brighttv.data.viewership;--inspecting second table contents

--DATA CLEANING VIEWERSHIP
--Checking for duplicate entries
SELECT COUNT(*),
       UserID0,
       RecordDate2
FROM viewership
GROUP BY UserID0, RecordDate2
HAVING COUNT(*)>1;---No duplicate entries where found in the dataset

SELECT COUNT(*),
       userid4,
       RecordDate2
FROM viewership
GROUP BY userid4, RecordDate2
HAVING COUNT(*)>1;---No duplicate entries where found in the dataset

SELECT UserID0,
       TO_DATE(RecordDate2) AS watch_date,
       date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
       date_format(`Duration 2`, 'HH:mm:ss') AS duration,
       Channel2
FROM viewership
WHERE userid0=810044;

--Removing duplicates
WITH cte1 AS (
SELECT DISTINCT *
FROM viewership
)
SELECT COUNT(*) AS duplicate_cnt,
       UserID0,
       TO_DATE(RecordDate2) AS watch_date,
       date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
       date_format(`Duration 2`, 'HH:mm:ss') AS duration,
        Channel2
FROM cte1
--WHERE userid0=810044
GROUP BY ALL
HAVING COUNT(*) > 1
ORDER BY duplicate_cnt DESC;

-------------------------------------------------------------
--select * 
--from viewership 
--where userid0=810044;
-------------------------------------------------------------
--Checking for missing values
SELECT *
FROM viewership
WHERE UserID0 IS NULL
OR userid4 IS NULL;

SELECT *
FROM viewership
WHERE UserID0 <>userid4;

--Checking the programs viewed on Channel2
SELECT *
FROM viewership
WHERE Channel2 IS NULL;

SELECT
     CASE 
         WHEN Channel2 IN ('Sawsee', 'SawSee') THEN 'Sawsee'--combining similar entries
         WHEN Channel2 IN ('Supersport Live Events','SuperSport Live Events', 'Live on SuperSport') THEN 'Live_sports_events'--classification of live events
         ELSE Channel2 ----retaining channels
    END AS Channel_watched
FROM viewership;

--Date transformation
SELECT 
 RecordDate2,
 TO_DATE (RecordDate2) As watch_date,----Converts a string into a date YYYY-MM-DD
 DAYNAME (TO_DATE(RecordDate2)) AS Day_name,--Extracts the day name
 MONTHNAME (TO_DATE(RecordDate2)) AS Month_name,--Extracts the month name
 YEAR (TO_DATE(RecordDate2)) as Year_name,---Exctracting the year
 DAY (TO_DATE(RecordDate2)) As Event_date, --Day name

    CASE
       WHEN Day_name IN ('Sat', 'Sun') THEN 'Weekend'
       ELSE 'Weekday'
    END AS Day_classification
FROM viewership
WHERE UserID0 IS NOT NULL
GROUP BY RecordDate2
ORDER BY Watch_date DESC;

----Analysing user_profiles
SELECT*
FROM brighttv.data.user_profiles;

--Checking for duplicates
SELECT COUNT (*),
       UserID
FROM user_profiles
GROUP BY UserID
HAVING COUNT (*) >1;

--Checking for missing values
SELECT *
FROM user_profiles
WHERE UserID IS NULL;

---Checking the different types of gender contained in the dataset.
SELECT DISTINCT Gender
FROM user_profiles;

--Transformation of gender entries to give them a meaningful classification.
SELECT DISTINCT
CASE
    WHEN Gender= 'None' THEN 'Unknown'--replacing gender none entries with Unknown
    WHEN Gender= ' ' THEN 'Unknown'-----replacing empty gender entries with Unknown
ELSE Gender-----------------------------retaining the gender if its male or female
END AS Gender_clean
FROM user_profiles;

--Checking the different types of race
SELECT DISTINCT Race
FROM user_profiles;

--Standardising the races that are not known into unknown
SELECT DISTINCT
CASE
    WHEN Race='other' THEN 'Unkown'---replacing the other race entry with Unknown
    WHEN Race='None' THEN 'Unkown'----replacing the none race entries with Unkown
    WHEN Race= ' ' THEN 'Unkown'------replacing empty entries with Unknown
Else Race-----------------------------retaining the known race entries
END AS Race_clean
From user_profiles;

--Checking the different types of provinces
SELECT DISTINCT Province
FROM user_profiles;
    
---Cleaning the unknown provinces
SELECT DISTINCT
               CASE
                  WHEN Province LIKE '%Non%' THEN 'Unknown'----replacing the none provinces with Unknown
                  WHEN Province = ' ' THEN 'Unknown'-----------replacing empty province entries with Unknown
               ELSE Province-----------------------------------retaining the existing known provinces
               END AS Province_clean
FROM user_profiles;

--Checking Age
SELECT 
       MIN(Age) As Minimum_age,--Checking the youngest age
       MAX (Age) AS Maximum_age,--Checking the highest age
       AVG (Age) AS Average_age--Checking the average age
FROM user_profiles;

SELECT DISTINCT Age
FROM user_profiles
WHERE Age IS NULL;

---Classifying Age into different Age buckets
SELECT 
      CASE
         WHEN Age BETWEEN 0 AND 5 THEN 'Infants'
         WHEN Age BETWEEN 6 AND 12 THEN 'Children'
         WHEN Age Between 13 AND 17 THEN 'Youths'
         WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
         WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
         WHEN Age BETWEEN 51 AND 65 THEN 'Elders'
         ELSE 'Pensioners'
      END AS Age_groups  
FROM user_profiles;

--Cleaning email column
SELECT UserID,
      CASE 
          WHEN (Email IS NOT NULL) AND (Email <> ' ') AND (Email NOT IN ('None', 'other')) THEN 1
          ELSE 0
      END AS Email_clean
FROM user_profiles;

--Cleaning social media handle
SELECT UserID,
    CASE
       WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle` <> ' ') OR (`Social Media Handle` NOT IN ('None', 'other')) THEN 1
       ELSE 0
    END AS Social_Media_Handle_Clean
FROM user_profiles;

--CTE helps to create a small table from somewhere
--------------------------------------------------------------

--Creating temporary tables for user_profiles and viewership and combining them into one big query (table)

WITH 
user_profiles AS (
SELECT UserID,
     CASE
         WHEN Gender= 'None' THEN 'Unknown'
         WHEN Gender= ' ' THEN 'Unknown'
         WHEN Gender IS NULL THEN 'Unknown'
     ELSE Gender
END AS Gender_clean,
     CASE
         WHEN Race='other' THEN 'Unkown'
         WHEN Race='None' THEN 'Unkown'
     Else Race
END AS Race_clean,
     CASE
         WHEN Province LIKE '%Non%' THEN 'Unknown'
         WHEN Province = ' ' THEN 'Unknown'
         ELSE Province
END AS Province_clean,

     CASE
         WHEN Age BETWEEN 0 AND 12 THEN 'Children'
         WHEN Age Between 13 AND 17 THEN 'Youth'
         WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
         WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
         WHEN Age BETWEEN 51 AND 65 THEN 'Elder'
         ELSE 'Pensioner'
      END AS Age_groups,
    CASE 
        WHEN (Email IS NOT NULL) AND (Email <> ' ') AND (Email NOT IN ('None', 'other')) THEN 1
        ELSE 0
      END AS Email_clean,
    CASE
       WHEN (`Social Media Handle` IS NOT NULL) AND (`Social Media Handle` <> ' ') AND (`Social Media Handle` NOT IN ('None', 'other')) THEN 1
       ELSE 0
    END AS Social_Media_Handle_Clean
FROM brighttv.data.user_profiles),

viewership AS (
SELECT  
     COALESCE (UserID0,userid4) AS Userid,---combining viewers ids into one
     TO_DATE (RecordDate2) As Watch_date,----Converts a string into a date YYYY-MM-DD
     MONTHNAME (TO_DATE(RecordDate2)) AS Month_name,--Extracts the month name
     YEAR (TO_DATE(RecordDate2)) as Year_name,---Exctracting the year
     DAY (TO_DATE(RecordDate2)) As Event_date, --Day name
     DAYNAME (TO_DATE(RecordDate2)) AS Day_name,--Extracts the day name
     HOUR (RecordDate2) AS Watch_hour,
     DATE_FORMAT(RecordDate2, 'HH:mm:ss') AS Watch_time,

    CASE -----classifying days into weekends and weekdays
         WHEN Day_name IN ('Sat', 'Sun') THEN 'Weekend'
         ELSE 'Weekday'
    END AS Day_classification,

     CASE --classification of times of day that the channel is watched
         WHEN Watch_time BETWEEN '00:00:00' AND '05:59:59' THEN 'Midnight'
         WHEN Watch_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
         WHEN Watch_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
         WHEN Watch_time BETWEEN '17:00:00' AND '24:59:59' THEN 'Evening'
    END AS Day_time,

     DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS Watch_duration,--transforming watch duration into time format

     CASE --grouping watch duration into screen time buckets
        WHEN Watch_duration BETWEEN '00:05:00' AND '00:30:00' THEN 'Low_usage'
        WHEN Watch_duration BETWEEN '00:30:01' AND '00:59:59' THEN 'Medium_usage'
        WHEN Watch_duration > '00:59:59' THEN 'High_usage'
        ELSE 'No_usage'
    END AS Screen_time,

     CASE 
         WHEN Channel2 IN ('Sawsee', 'SawSee') THEN 'Sawsee'--combining similar entries
         WHEN Channel2 IN ('Supersport Live Events', 'DStv Events 1','SuperSport Live Events', 'Live on SuperSport') THEN 'Live_events'--classification of live events
         ELSE Channel2 ----retaining channels
    END AS Channel_watched
FROM brighttv.data.viewership)

--Big Query
SELECT COALESCE (user_profiles.UserID, viewership.Userid) AS Sub_id,
                                       Gender_clean, 
                                       Race_clean, 
                                       Province_clean, 
                                       Age_groups, 
                                       Email_clean, 
                                       Social_Media_Handle_Clean,
                                       Year_name,
                                       Month_name,
                                       Day_name,
                                       Watch_date,  
                                       Event_date, 
                                       Day_classification,
                                       Watch_hour,
                                       Day_time,
                                       Watch_duration,
                                       Screen_time,
                                       Channel_watched
FROM user_profiles 
LEFT JOIN viewership 
ON user_profiles.UserID = viewership.Userid;




