-- Databricks notebook source
With user_profiles AS
(SELECT UserID,
           CASE ---Creating gender classification
                 WHEN Gender = 'None' THEN 'unknown' 
                 WHEN Gender = ' ' THEN 'unknown' 
                 WHEN Gender IS NULL THEN 'unknown' 
                 ELSE Gender 
              END AS Sex,
               
             CASE---classifying race
                 WHEN Race = 'None' THEN 'unknown' 
                 WHEN Race = ' ' THEN 'unknown' 
                 WHEN Race = 'other' THEN 'unknown' 
                 WHEN Race IS NULL THEN 'unknown' 
                 ELSE Race 
             END AS Ethnicity,

            CASE ---classifying Age
               WHEN Age = 0 THEN 'infant' 
               WHEN Age BETWEEN 1 AND 12 THEN 'Kids' 
               WHEN Age BETWEEN 13 AND 17 THEN 'Teenagers' 
               WHEN Age BETWEEN 18 AND 35 THEN 'Youths' 
               WHEN Age BETWEEN 36 AND 50 THEN 'Adults' 
               WHEN Age > 50 AND Age<=60 THEN 'Elders' 
               WHEN Age > 60 THEN 'Pensioners' 
            END AS Age_group,

          CASE --classifying province
                WHEN Province = 'None' THEN 'Unclassified' 
                WHEN Province = ' ' THEN 'Unclassified' 
                WHEN Province = 'other' THEN 'Unclassified' 
                WHEN Province IS NULL THEN 'Unclassified' 
                ELSE Province 
             END AS Regions,

          CASE --classifying email
                WHEN 'Email' IS NOT NULL THEN 1 
                WHEN 'Email'<> ' ' THEN 1 
                ELSE 0 
           END AS Email_flag, 

        CASE --classifying social media handle
            WHEN 'Social Media Handle' IS NOT NULL THEN 1 
            ELSE 0 
        END AS Social_media_handle_flag
     
    FROM brighttv.data.user_profiles)

    select*
    from user_profiles;


