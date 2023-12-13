CREATE TABLE appleStore_description_combined AS
SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
union all
select * from appleStore_description3
union ALL
select * from appleStore_description4

**EXPLORATORY DATA ANALYSIS**

--Check the number of unique apps in both tablesAppleStore

select count(distinct id) as UniqueAppIDs
From AppleStore

select count(distinct id) as UniqueAppIDs
From appleStore_description_combined

--Check for any missing values in key fields

select count(*) as MissingValues
from AppleStore
where track_name is null or user_rating is null or prime_genre is NULL

select count(*) as MissingValues
from appleStore_description_combined
where app_desc is null

--Find out the number of apps per genre

select prime_genre, count(*) as NumApps
from AppleStore
group by prime_genre
order by NumApps DESC


--Get an overview of the apps' ratings 

select min(user_rating) as MinRating,
	   max(user_rating) As MaxRating,
       avg(user_rating) as AvgRating
from AppleStore

**DATA ANALYSIS**

--Determine whether paid apps have higher ratings than free apps

select CASE
			when price > 0 then 'Paid'
            else 'Free'
       End As App_Type,
       avg(user_rating) as Avg_Rating
from AppleStore
group by App_Type

--Check if apps with more supported languages have higher ratings

select CASE
			when lang_num < 10 then '<10 languages'
            when lang_num between 10 and 30 then '10-30 languages'
            else '>30 languages'
       end as language_bucket,
       avg(user_rating) as Avg_rating
From AppleStore
group by language_bucket
order by Avg_Rating DESC

--Check genres with low ratings

SELECT prime_genre,
	   avg(user_rating) as Avg_Rating
From AppleStore
group by prime_genre
order by Avg_Rating ASC
limit 10

--Check if there is correlation between the length of the app description and the user rating

SELECT CASE
			when length(b.app_desc) < 500 then 'Short'
            when length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
            else 'Long'
       End as description_length_bucket,
       avg(a.user_rating) as average_rating
from
	AppleStore as a
Join
	appleStore_description_combined as b
ON
	a.id = b.id
group by description_length_bucket
order by average_rating DESC

--Check the top-rated apps for each genre

select 
	prime_genre,
	track_name,
    user_rating
from (
	  select 
	  prime_genre,
	  track_name,
      user_rating,
      RANK() OVER(PARTITION by prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) as rank
      from
  	  AppleStore
    ) as a
WHERE
a.rank = 1