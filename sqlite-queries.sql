create table appleStore_description_combined as
select * from appleStore_description1
union all
select * from appleStore_description2
union all
select * from appleStore_description3
union all
select * from appleStore_description4

**EXPLORATORY DATA ANALYSIS**

--Check the number of unique apps in both tablesAppleStore

select count(distinct id) as UniqueAppIDs
from AppleStore

select count(distinct id) as UniqueAppIDs
from appleStore_description_combined

--Check for any missing values in key fields

select count(*) as MissingValues
from AppleStore
where track_name is null or user_rating is null or prime_genre is null

select count(*) as MissingValues
from appleStore_description_combined
where app_desc is null

--Find out the number of apps per genre

select prime_genre, count(*) as NumApps
from AppleStore
group by prime_genre
order by NumApps desc


--Get an overview of the apps' ratings 

select min(user_rating) as MinRating,
       max(user_rating) As MaxRating,
       avg(user_rating) as AvgRating
from AppleStore

**DATA ANALYSIS**

--Determine whether paid apps have higher ratings than free apps

select case
	    when price > 0 then 'Paid'
            else 'Free'
       end as App_Type,
       avg(user_rating) as Avg_Rating
from AppleStore
group by App_Type

--Check if apps with more supported languages have higher ratings

select case
	    when lang_num < 10 then '<10 languages'
            when lang_num between 10 and 30 then '10-30 languages'
            else '>30 languages'
       end as language_bucket,
       avg(user_rating) as Avg_Rating
from AppleStore
group by language_bucket
order by Avg_Rating desc

--Check genres with low ratings

select prime_genre,
       avg(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_Rating asc
limit 10

--Check if there is correlation between the length of the app description and the user rating

select case
	    when length(b.app_desc) < 500 then 'Short'
            when length(b.app_desc) between 500 and 1000 then 'Medium'
            else 'Long'
       end as description_length_bucket,
       avg(a.user_rating) as average_rating
from
	AppleStore as a
join
	appleStore_description_combined as b
on
	a.id = b.id
group by description_length_bucket
order by average_rating desc

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
     )  as a
WHERE
a.rank = 1
