-- Databricks notebook source
USE brighttv.data;

SELECT*
FROM brighttv.data.user_profiles;

SELECT *
FROM brighttv.data.viewership;

-------------------------------------------------------------------------------
--Data types
-------------------------------------------------------------------------------
--Int (integer is a number without a decimal)
--str (string/object) is a combination of characters (a-z, B-9,/,.,>!)
--Gender checks
--DateTme, Timestamp, its a date

------------------------------------------------------------------------------
--Date functions
--they are built to deal with dates
--help to manipulate date columns

--Transforming dates
SELECT 
 RecordDate2,
 TO_DATE(RecordDate2) As watch_date,----Converts a string into a date YYYY-MM-DD
 DAYNAME (TO_DATE(RecordDate2)) AS Day_name,--Extracts the day name
 MONTHNAME (TO_DATE(RecordDate2)) AS Month_name,--Extracts the month name
 YEAR (TO_DATE(RecordDate2)) as Year_name,---Exctracting the year
 DAY (TO_DATE(RecordDate2)) As Event_date --Day name
FROM viewership;

SELECT
     COUNT(DISTINCT UserID0) AS number_of_subs,
     RecordDate2,
     TO_DATE(RecordDate2) AS watch_date,
     DAYNAME (TO_DATE(RecordDate2)) AS Day_name,
     CASE
         WHEN Day_name IN ('Sat', 'Sun') THEN 'Weekend'
         ELSE 'Weekday'
    END AS day_classification,
    MONTHNAME (TO_DATE(RecordDate2)) AS Month_name,--Extracts the month name
    YEAR (TO_DATE(RecordDate2)) as Year_name,---Exctracting the year
    DAY (TO_DATE(RecordDate2)) As Event_date --Day name
 FROM viewership
 WHERE UserID0 IS NOT NULL
 GROUP BY RecordDate2
 ORDER BY watch_date DESC;

 --SELECT SUM(number_of_subs) AS subs,
      -- day_classification,

----Analysing user_profiles
SELECT*
FROM brighttv.data.user_profiles;

---Checking the different types of gender contained in the dataset.
SELECT DISTINCT Gender
FROM user_profiles;

--Transformation of gender entries to give them a meaningful classification.
SELECT DISTINCT
CASE
    WHEN Gender= 'None' THEN 'Unknown'
    WHEN Gender= ' ' THEN 'Unknown'
    WHEN Gender= 'NULL' THEN 'Unknown'
ELSE Gender
END AS Gender_clean
FROM user_profiles;

--Checking the different types of race
SELECT DISTINCT Race
FROM user_profiles;

--Transforming the races that are not known into unknown
SELECT DISTINCT
CASE
    WHEN Race='other' THEN 'Unkown'
    WHEN Race='None' THEN 'Unkown'
Else Race
END AS Race_clean
From user_profiles;

--Checking on the different types of provinces
SELECT DISTINCT Province
FROM user_profiles;
    
---Renaming the unknown provinces
SELECT DISTINCT
               CASE
                  WHEN Province LIKE '%Non%' THEN 'Unknown'
                  WHEN Province = ' ' THEN 'Unknown'
               ELSE Province
               END AS Province_clean
FROM user_profiles;

---Creating Age buckets
SELECT *,
      CASE
          WHEN Age BETWEEN 0 AND 12 THEN 'Children'
          WHEN Age Between 12 AND 35 THEN 'Youth'
          ELSE 'Adult'
      END AS Age_groups
FROM user_profiles;

--CREATING BIG QUERY TABLE FOR USER PROFILES
SELECT *,
     CASE
         WHEN Gender= 'None' THEN 'Unknown'
         WHEN Gender= ' ' THEN 'Unknown'
         WHEN Gender= 'NULL' THEN 'Unknown'
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
         WHEN Age Between 12 AND 35 THEN 'Youth'
         ELSE 'Adult'
      END AS Age_groups
FROM user_profiles;



