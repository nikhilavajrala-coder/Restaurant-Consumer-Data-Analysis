create database restaurant;
use restaurant;

-- consumers table
create table consumers (
    consumer_id varchar(10) primary key,
    city varchar(255),
    state varchar(255),
    country varchar(255),
    latitude decimal(10,7),
    longitude decimal(10,7),
    smoker varchar(10),
    drink_level varchar(50),
    transportation_method varchar(50),
    marital_status varchar(20),
    children varchar(20),
    age int,
    occupation varchar(50),
    budget varchar(10)
);

-- consumer preferences table
create table consumer_preferences (
    consumer_id varchar(10),
    preferred_cuisine varchar(255),
    primary key (consumer_id, preferred_cuisine),
    foreign key (consumer_id) references consumers(consumer_id)
);

-- restaurants table
create table restaurants (
    restaurant_id int primary key,
    name varchar(255),
    city varchar(255),
    state varchar(255),
    country varchar(255),
    zip_code varchar(10),
    latitude decimal(10,8),
    longitude decimal(11,8),
    alcohol_service varchar(50),
    smoking_allowed varchar(50),
    price varchar(10),
    franchise varchar(5),
    area varchar(10),
    parking varchar(50)
);

-- restaurant cuisines table
create table restaurant_cuisines (
    restaurant_id int,
    cuisine varchar(255),
    primary key (restaurant_id, cuisine),
    foreign key (restaurant_id) references restaurants(restaurant_id)
);

-- ratings table
create table ratings (
    consumer_id varchar(10),
    restaurant_id int,
    overall_rating int,
    food_rating int,
    service_rating int,
    primary key (consumer_id, restaurant_id),
    foreign key (consumer_id) references consumers(consumer_id),
    foreign key (restaurant_id) references restaurants(restaurant_id)
);

-- List all details of consumers who live in the city of 'Cuernavaca'.
select consumer_id, city
from consumers
where city = 'Cuernavaca';

-- Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
select consumer_id, age, occupation
from consumers
where occupation = 'student'
and smoker = 'yes';

-- List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.

select name, city, alcohol_service, price
from restaurants
where alcohol_service ='Wine & Beer' and price = 'Medium';

-- Find the names and cities of all restaurants that are part of a 'Franchise'.

select name, city
from restaurants
where franchise = 'yes';

-- Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the data dictionary).

select consumer_id, restaurant_id, overall_rating
from ratings
where overall_rating = 2;

-- List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.

select distinct r.name, r.city
from restaurants r
join ratings rt
on r.restaurant_id = rt.restaurant_id
where rt.overall_rating = 2;

-- Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
select c.consumer_id, c.age
from consumers c
join ratings r
on c.consumer_id = r.consumer_id
join restaurants rs
on r.restaurant_id = rs.restaurant_id
where rs.city = 'San Luis Potosi';

-- List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
select r.name, rc.cuisine
from restaurants r
join restaurant_cuisines rc
on r.restaurant_id = rc.restaurant_id
join ratings rs
on rs.restaurant_id = r.restaurant_id
where rc.cuisine = 'mexican' and rs.consumer_id = 'U1001';

-- Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
select c.consumer_id, c.age
from consumers c
join ratings r
on r.consumer_id = c.consumer_id
join restaurants rs
on rs.restaurant_id = r.restaurant_id
join restaurant_cuisines rc
on rs.restaurant_id = rc.restaurant_id
where rc.cuisine = 'American' and c.budget = 'medium';

-- List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
select distinct r.name, r.city
from restaurants r
join ratings rs
on r.restaurant_id = rs.restaurant_id
where rs.food_rating < (select avg(food_rating) from ratings);

-- Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.

select distinct c.consumer_id, c.age, c.occupation
from consumers c
join ratings r
  on c.consumer_id = r.consumer_id
where c.consumer_id in (select consumer_id from ratings)
and c.consumer_id not in (select r.consumer_id
    from ratings r
    join restaurant_cuisines rc
	on r.restaurant_id = rc.restaurant_id
    where rc.cuisine = 'italian');

-- List restaurants (Name) that have received ratings from consumers older than 30.

select r.name
from restaurants r
join ratings rs
on rs.restaurant_id = r.restaurant_id
join consumers c
on c.consumer_id = rs.consumer_id
where c.age > 30;

-- Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
select distinct c.consumer_id, c.occupation
from consumers c
join consumer_preferences cp
on c.consumer_id = cp.consumer_id
join ratings r
on c.consumer_id = r.consumer_id
where cp.preferred_cuisine = 'mexican' and r.overall_rating = 0;


-- List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
select distinct r.name, r.city
from restaurants r
join restaurant_cuisines rc
on r.restaurant_id = rc.restaurant_id
where rc.cuisine = 'pizzeria'and r.city in (
      select distinct c.city
      from consumers c
      where c.occupation = 'student');
      
-- Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.

select distinct c.consumer_id, c.age
from consumers c
join ratings r
on c.consumer_id = r.consumer_id
join restaurants rs
on r.restaurant_id = rs.restaurant_id
where c.drink_level = 'social drinker'
and rs.parking = 'no';

-- List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. Show only students who have rated more than 2 restaurants.
select c.consumer_id, count(r.restaurant_id)
from consumers c

join ratings r
on c.consumer_id = r.consumer_id
where c.occupation = 'student'
group by c.consumer_id
having count(r.restaurant_id) > 2;

-- We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be exactly 2 and who use 'Public' 

select consumer_id, age, (age/10) as Engagement_Score
from consumers
where age/10 = 2 and transportation_method = 'public';

-- For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.

select r.name, r.city, avg(rs.overall_rating)
from restaurants r
join ratings rs
where r.city = 'Cuernavaca' 
group by r.name, r.city
having avg(rs.overall_rating) > 1.0;

-- Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings where the Overall_Rating was 2.

select c.consumer_id, c.age
from consumers c
join ratings r
on c.consumer_id = r.consumer_id
where c.marital_status = 'Married'
and r.food_rating = r.service_rating
and r.overall_rating = 2;

-- List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' and have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.

select c.consumer_id, c.age, r.name
from consumers c
join ratings rs
on c.consumer_id = rs.consumer_id
join restaurants r
on r.restaurant_id = rs.restaurant_id
where c.occupation = 'employed'
and rs.food_rating = 0
and r.city = 'ciudad victoria';

-- Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.
with special as( select consumer_id, age
from consumers
where city = 'San Luis Potosi')
select distinct sc.consumer_id, sc.age, r.name
from special sc
join ratings rs
on sc.consumer_id = rs.consumer_id
join restaurants r
on r.restaurant_id = rs.restaurant_id
join restaurant_cuisines rc
on r.restaurant_id = rc.restaurant_id
where rc.cuisine = 'mexican'
and rs.overall_rating = 2;

-- For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. (Use a derived table to get consumers who have rated).

select c.occupation, avg(c.age) as avg_age
from consumers c
join (select distinct consumer_id
from ratings
) rated_consumers
on c.consumer_id = rated_consumers.consumer_id
group by c.occupation;

-- Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.

with res as(select r.restaurant_id, rs.consumer_id, rs.overall_rating
from restaurants r
join ratings rs
on r.restaurant_id = rs.restaurant_id
where r.city = 'cuernavaca')
select restaurant_id,consumer_id,overall_rating,
rank() over (partition by restaurant_id 
order by overall_rating desc) as rating_rank
from res;

-- For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the average Overall_Rating given by that specific consumer across all their ratings.

select rs.consumer_id, rs.restaurant_id, rs.overall_rating, avg(overall_rating) 
over (partition by rs.consumer_id)
from ratings rs;

-- Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).

with low_budget_students as (select consumer_id, age
from consumers
where occupation = 'student'and budget = 'low'),
ranked_preferences as (select cp.consumer_id,cp.preferred_cuisine,
row_number() over (partition by cp.consumer_id
order by cp.consumer_id, cp.preferred_cuisine) as pref_rank
from consumer_preferences cp
join low_budget_students lbs
on cp.consumer_id = lbs.consumer_id)
select consumer_id, preferred_cuisine
from ranked_preferences
where pref_rank <= 3
order by consumer_id, pref_rank;

-- Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). Use a derived table to filter for the consumer's ratings first.

-- First filter ratings for Consumer_ID = 'U1008' using a derived table
with u1008_ratings as (select restaurant_id, overall_rating
from ratings
where consumer_id = 'U1008')
select restaurant_id,overall_rating,
lead(overall_rating) over (order by restaurant_id) as next_overall_rating
from u1008_ratings;

-- Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.

create view HighlyRatedMexicanRestaurants as
select r.restaurant_id,r.name,r.city
from restaurants r
join ratings rs
on r.restaurant_id = rs.restaurant_id
join restaurant_cuisines rc
on r.restaurant_id = rc.restaurant_id
where rc.cuisine = 'mexican'
group by r.restaurant_id, r.name, r.city
having avg(rs.overall_rating) > 1.5;

-- First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.

with mexican_pref_consumers as (select consumer_id
from consumer_preferences
where preferred_cuisine = 'mexican')
select distinct mpc.consumer_id
from mexican_pref_consumers mpc
where mpc.consumer_id not in (select rs.consumer_id
from ratings rs
join HighlyRatedMexicanRestaurants hr
on rs.restaurant_id = hr.restaurant_id);

-- Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input. It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating meets or exceeds the threshold.

delimiter //
create procedure GetRestaurantRatingsAboveThreshold(in threshold float)
begin
    select r.restaurant_id,r.name,r.city,avg(rs.overall_rating) as avg_rating
    from restaurants r
    join ratings rs
	on r.restaurant_id = rs.restaurant_id
    group by r.restaurant_id, r.name, r.city
    having avg(rs.overall_rating) > threshold;
end//
delimiter ;

-- Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.-- Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.

with cuisine_ratings as (select rc.cuisine,r.name as restaurant_name,r.city,rs.overall_rating,
dense_rank() over (partition by rc.cuisine
order by rs.overall_rating desc) as rating_rank
from restaurants r
join ratings rs
on r.restaurant_id = rs.restaurant_id
join restaurant_cuisines rc
on r.restaurant_id = rc.restaurant_id)
select cuisine,restaurant_name,city,overall_rating
from cuisine_ratings
where rating_rank <= 2
order by cuisine, rating_rank, restaurant_name;

-- First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating. Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.

create view ConsumerAverageRatings as
select consumer_id,avg(overall_rating) as avg_rating
from ratings
group by consumer_id;
with top_consumers as (select consumer_id, avg_rating,
dense_rank() over (order by avg_rating desc) as rating_rank
from ConsumerAverageRatings)
select tc.consumer_id,tc.avg_rating,
count(distinct rs.restaurant_id) as mexican_restaurants_rated
from top_consumers tc
join ratings rs
on tc.consumer_id = rs.consumer_id
join restaurant_cuisines rc
on rs.restaurant_id = rc.restaurant_id
where rc.cuisine = 'mexican'
and tc.rating_rank <= 5
group by tc.consumer_id, tc.avg_rating
order by tc.avg_rating desc;

/* Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.

The procedure should:
Determine the consumer's "Spending Segment" based on their Budget:
'Low' -> 'Budget Conscious'
'Medium' -> 'Moderate Spender'
'High' -> 'Premium Spender'
NULL or other -> 'Unknown Budget'


For all restaurants rated by this consumer:
List the Restaurant_Name.
The Overall_Rating given by this consumer.
The average Overall_Rating this restaurant has received from all consumers (not just the input consumer).
A "Performance_Flag" indicating if the input consumer's rating for that restaurant is 'Above Average', 'At Average', or 'Below Average' compared to the restaurant's overall average rating.
Rank these restaurants for the input consumer based on the Overall_Rating they gave (highest rating = rank 1).

*/

delimiter $$

create procedure GetConsumerSegmentAndRestaurantPerformance(in consumer_id_input varchar(20))
begin
    select case c.budget
               when 'low' then 'Budget Conscious'
               when 'medium' then 'Moderate Spender'
               when 'high' then 'Premium Spender'
               else 'Unknown Budget'
           end as spending_segment
    from consumers c
    where c.consumer_id = consumer_id_input;
    select r.name as restaurant_name,
           rs.overall_rating as consumer_rating,
           avg(rs2.overall_rating) as avg_restaurant_rating,
           case
               when rs.overall_rating > avg(rs2.overall_rating) then 'Above Average'
               when rs.overall_rating = avg(rs2.overall_rating) then 'At Average'
               else 'Below Average'
           end as performance_flag,
           rank() over (order by rs.overall_rating desc) as consumer_rating_rank
    from ratings rs
    join restaurants r
	on rs.restaurant_id = r.restaurant_id
    join ratings rs2
	on r.restaurant_id = rs2.restaurant_id
    where rs.consumer_id = consumer_id_input
    group by r.name, rs.overall_rating, rs.restaurant_id;
end$$

delimiter ;
