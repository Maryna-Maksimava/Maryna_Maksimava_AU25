--1
---------------------------------
--The marketing team needs a list of animation movies
-- between 2017 and 2019 to promote family-friendly content
-- in an upcoming season in stores. Show all animation movies
-- released during this period with rate more than 1, sorted alphabetically

-- join-based solution
-- straightforward and performant for relational filtering

select distinct f.title
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
where lower(c.name) = 'animation'
  and f.release_year between 2017 and 2019
  and f.rental_rate > 1
order by f.title;

-- subquery-based solution
-- isolates category filtering logic

select title
from film
where film_id in (
    select fc.film_id
    from film_category fc
    join category c on c.category_id = fc.category_id
    where lower(c.name) = 'animation'
)
and release_year between 2017 and 2019
and rental_rate > 1
order by title;

-- cte-based solution
-- good for readability and reuse

with animation_movies as (
    select 
        f.film_id,
        f.title,
        f.release_year,
        f.rental_rate
    from film f
    join film_category fc on f.film_id = fc.film_id
    join category c on c.category_id = fc.category_id
    where lower(c.name) = 'animation'
)
select title
from animation_movies
where release_year between 2017 and 2019
  and rental_rate > 1
order by title;


--1.2--------------------------------------------------

-- join-based solution
-- calculates total revenue per store since 2017-04-01

select
    s.store_id,
    concat(a.address, ', ', coalesce(a.address2, '')) as full_address,
    sum(p.amount) as revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join store s on i.store_id = s.store_id
join address a on s.address_id = a.address_id
where p.payment_date >= '2017-04-01'
group by s.store_id, a.address, a.address2
order by revenue desc;

-- subquery-based solution
-- first calculates revenue per store, then joins address info

select
    s.store_id,
    concat(a.address, ', ', coalesce(a.address2, '')) as full_address,
    sr.revenue
from (
    select
        i.store_id,
        sum(p.amount) as revenue
    from payment p
    join rental r on p.rental_id = r.rental_id
    join inventory i on r.inventory_id = i.inventory_id
    where p.payment_date >= '2017-04-01'
    group by i.store_id
) sr
join store s on sr.store_id = s.store_id
join address a on s.address_id = a.address_id
order by sr.revenue desc;

-- cte-based solution
-- improves readability and makes logic reusable

with store_revenue as (
    select
        i.store_id,
        sum(p.amount) as revenue
    from payment p
    join rental r on p.rental_id = r.rental_id
    join inventory i on r.inventory_id = i.inventory_id
    where p.payment_date >= '2017-04-01'
    group by i.store_id
)
select
    sr.store_id,
    concat(a.address, ', ', coalesce(a.address2, '')) as full_address,
    sr.revenue
from store_revenue sr
join store s on sr.store_id = s.store_id
join address a on s.address_id = a.address_id
order by sr.revenue desc;


--1.3-----------------------------------------------------

-- top 5 actors by number of movies released after 2015
--join-based solution

select 
    a.first_name,
    a.last_name,
    count(f.film_id) as number_of_movies
from actor a
join film_actor fa on fa.actor_id = a.actor_id
join film f on f.film_id = fa.film_id
where f.release_year > 2015
group by a.actor_id
order by number_of_movies desc
limit 5;

-- subquery-based solution
select first_name, last_name, number_of_movies
from (
    select 
        a.actor_id,
        a.first_name,
        a.last_name,
        count(f.film_id) as number_of_movies
    from actor a
    join film_actor fa on fa.actor_id = a.actor_id
    join film f on f.film_id = fa.film_id
    where f.release_year > 2015
    group by a.actor_id
) t
order by number_of_movies desc
limit 5;

-- cte-based solution
with actor_movies as (
    select 
        a.actor_id,
        a.first_name,
        a.last_name,
        count(f.film_id) as number_of_movies
    from actor a
    join film_actor fa on fa.actor_id = a.actor_id
    join film f on f.film_id = fa.film_id
    where f.release_year > 2015
    group by a.actor_id
)
select *
from actor_movies
order by number_of_movies desc
limit 5;

------1.4-------------------------------------
-- join-based solution
-- the straightforward approach

select
    f.release_year,
    count(case when lower(c.name) = 'drama' then 1 end) as number_of_drama_movies,
    count(case when lower(c.name) = 'travel' then 1 end) as number_of_travel_movies,
    count(case when lower(c.name) = 'documentary' then 1 end) as number_of_documentary_movies
from film f
left join film_category fc on f.film_id = fc.film_id
left join category c on fc.category_id = c.category_id
group by f.release_year
order by f.release_year desc;

-- subquery-based solution
-- isolates film-category mapping logic

select
    release_year,
    count(case when lower(name) = 'drama' then 1 end) as number_of_drama_movies,
    count(case when lower(name) = 'travel' then 1 end) as number_of_travel_movies,
    count(case when lower(name) = 'documentary' then 1 end) as number_of_documentary_movies
from (
    select
        f.release_year,
        c.name
    from film f
    left join film_category fc on f.film_id = fc.film_id
    left join category c on fc.category_id = c.category_id
) t
group by release_year
order by release_year desc;

-- cte-based solution
-- improves readability and reusability

with film_categories as (
    select
        f.release_year,
        lower(c.name) as category_name
    from film f
    left join film_category fc on f.film_id = fc.film_id
    left join category c on fc.category_id = c.category_id
)
select
    release_year,
    count(case when category_name = 'drama' then 1 end) as number_of_drama_movies,
    count(case when category_name = 'travel' then 1 end) as number_of_travel_movies,
    count(case when category_name = 'documentary' then 1 end) as number_of_documentary_movies
from film_categories
group by release_year
order by release_year desc;



----------------------------------
--2
---2.1---------------------------------------------

-- determines total revenue per staff in 2017
-- and the latest store they worked in based on last payment date
-- cte-based solution
--Very readable
--Easy to debug and extend
--Best for analytics

with staff_revenue_2017 as (
    select 
        p.staff_id,
        s.first_name,
        s.last_name,
        i.store_id,
        sum(p.amount) as total_revenue,
        max(p.payment_date) as last_payment_date
    from payment p
    join rental r on p.rental_id = r.rental_id
    join inventory i on r.inventory_id = i.inventory_id
    join staff s on p.staff_id = s.staff_id
    where p.payment_date between '2017-01-01' and '2017-12-31'
    group by p.staff_id, s.first_name, s.last_name, i.store_id
),
latest_store as (
    -- select latest store per staff member
    select distinct on (staff_id)
        staff_id,
        store_id
    from staff_revenue_2017
    order by staff_id, last_payment_date desc
),
total_revenue_2017 as (
    -- total revenue per staff for 2017
    select 
        staff_id,
        sum(amount) as total_revenue
    from payment
    where payment_date between '2017-01-01' and '2017-12-31'
    group by staff_id
)
select 
    s.staff_id,
    s.first_name,
    s.last_name,
    ls.store_id,
    concat(a.address, ', ', coalesce(a.address2, '')) as store_address,
    round(tr.total_revenue, 2) as total_revenue
from latest_store ls
join staff s on ls.staff_id = s.staff_id
join store st on ls.store_id = st.store_id
join address a on st.address_id = a.address_id
join total_revenue_2017 tr on s.staff_id = tr.staff_id
order by total_revenue desc
limit 3;

-- subquery-based solution
-- embeds revenue and latest-store logic inside nested queries

select
    s.staff_id,
    s.first_name,
    s.last_name,
    ls.store_id,
    concat(a.address, ', ', coalesce(a.address2, '')) as store_address,
    round(tr.total_revenue, 2) as total_revenue
from (
    -- latest store per staff
    select distinct on (p.staff_id)
        p.staff_id,
        i.store_id
    from payment p
    join rental r on p.rental_id = r.rental_id
    join inventory i on r.inventory_id = i.inventory_id
    where p.payment_date between '2017-01-01' and '2017-12-31'
    order by p.staff_id, p.payment_date desc
) ls
join staff s on ls.staff_id = s.staff_id
join (
    -- total revenue per staff
    select
        staff_id,
        sum(amount) as total_revenue
    from payment
    where payment_date between '2017-01-01' and '2017-12-31'
    group by staff_id
) tr on s.staff_id = tr.staff_id
join store st on ls.store_id = st.store_id
join address a on st.address_id = a.address_id
order by total_revenue desc
limit 3;

-- join  solution
-- combines all logic in a single query using joins

select
    s.staff_id,
    s.first_name,
    s.last_name,
    i.store_id,
    concat(a.address, ', ', coalesce(a.address2, '')) as store_address,
    round(tr.total_revenue, 2) as total_revenue
from staff s

-- total revenue per staff in 2017
join (
    select
        staff_id,
        sum(amount) as total_revenue
    from payment
    where payment_date between '2017-01-01' and '2017-12-31'
    group by staff_id
) tr on s.staff_id = tr.staff_id

-- latest payment date per staff
join (
    select
        staff_id,
        max(payment_date) as last_payment_date
    from payment
    where payment_date between '2017-01-01' and '2017-12-31'
    group by staff_id
) lp on s.staff_id = lp.staff_id

-- connect latest payment to rental → inventory → store
join payment p 
    on p.staff_id = lp.staff_id 
   and p.payment_date = lp.last_payment_date
join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join store st on i.store_id = st.store_id
join address a on st.address_id = a.address_id

order by total_revenue desc
limit 3;

----2.2--------------------------------------
-- join-based solution
-- counts rentals per film and maps rating to expected audience age

select
    f.film_id,
    f.title,
    f.rating,
    count(r.rental_id) as rental_count,
    case f.rating
        when 'G' then 'all ages'
        when 'PG' then 'parental guidance (8+)'
        when 'PG-13' then 'teens (13+)'
        when 'R' then 'adults (17+)'
        when 'NC-17' then 'adults only (18+)'
        else 'unrated/unknown'
    end as expected_audience_age
from film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by f.film_id, f.title, f.rating
order by rental_count desc
limit 5;

-- subquery-based solution
-- separates rental counting from presentation logic

select
    film_id,
    title,
    rating,
    rental_count,
    case rating
        when 'G' then 'all ages'
        when 'PG' then 'parental guidance (8+)'
        when 'PG-13' then 'teens (13+)'
        when 'R' then 'adults (17+)'
        when 'NC-17' then 'adults only (18+)'
        else 'unrated/unknown'
    end as expected_audience_age
from (
    select
        f.film_id,
        f.title,
        f.rating,
        count(r.rental_id) as rental_count
    from film f
    join inventory i on f.film_id = i.film_id
    join rental r on i.inventory_id = r.inventory_id
    group by f.film_id, f.title, f.rating
) t
order by rental_count desc
limit 5;

-- cte-based solution
-- improves readability and reuse

with film_rentals as (
    select
        f.film_id,
        f.title,
        f.rating,
        count(r.rental_id) as rental_count
    from film f
    join inventory i on f.film_id = i.film_id
    join rental r on i.inventory_id = r.inventory_id
    group by f.film_id, f.title, f.rating
)
select
    film_id,
    title,
    rating,
    rental_count,
    case rating
        when 'G' then 'all ages'
        when 'PG' then 'parental guidance (8+)'
        when 'PG-13' then 'teens (13+)'
        when 'R' then 'adults (17+)'
        when 'NC-17' then 'adults only (18+)'
        else 'unrated/unknown'
    end as expected_audience_age
from film_rentals
order by rental_count desc
limit 5;


------------------
--3
-------------
-- join-based solution
-- calculates years since actor's most recent movie

select
    a.actor_id,
    concat(a.first_name, ' ', a.last_name) as actor_name,
    max(f.release_year) as last_release_year,
    extract(year from current_date) - max(f.release_year) as inactivity_years
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
group by a.actor_id, actor_name
order by inactivity_years desc;

-- subquery-based solution
-- isolates aggregation of last release year

select
    actor_id,
    actor_name,
    last_release_year,
    extract(year from current_date) - last_release_year as inactivity_years
from (
    select
        a.actor_id,
        concat(a.first_name, ' ', a.last_name) as actor_name,
        max(f.release_year) as last_release_year
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    join film f on fa.film_id = f.film_id
    group by a.actor_id, actor_name
) t
order by inactivity_years desc;

-- cte-based solution
-- improves readability and reusability

with actor_last_release as (
    select
        a.actor_id,
        concat(a.first_name, ' ', a.last_name) as actor_name,
        max(f.release_year) as last_release_year
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    join film f on fa.film_id = f.film_id
    group by a.actor_id, actor_name
)
select
    actor_id,
    actor_name,
    last_release_year,
    extract(year from current_date) - last_release_year as inactivity_years
from actor_last_release
order by inactivity_years desc;

-------------------------
-- biggest gap between movie releases per actor
-- join-only solution 
-- finds consecutive release years using self-join

select
    a.actor_id,
    concat(a.first_name, ' ', a.last_name) as actor_name,
    max(f2.release_year - f1.release_year) as biggest_gap_years
from actor a
join film_actor fa1 on a.actor_id = fa1.actor_id
join film f1 on fa1.film_id = f1.film_id

join film_actor fa2 on a.actor_id = fa2.actor_id
join film f2 on fa2.film_id = f2.film_id

-- ensure f2 is the next movie after f1
where f2.release_year > f1.release_year
  and not exists (
      select 1
      from film_actor fa3
      join film f3 on fa3.film_id = f3.film_id
      where fa3.actor_id = a.actor_id
        and f3.release_year > f1.release_year
        and f3.release_year < f2.release_year
  )
group by a.actor_id, actor_name
order by biggest_gap_years desc;


-- subquery-based solution
-- isolates gap calculation logic

select
    actor_id,
    actor_name,
    max(gap_years) as biggest_gap_years
from (
    select 
        a.actor_id,
        concat(a.first_name, ' ', a.last_name) as actor_name,
        f.release_year
        - lag(f.release_year) over (
            partition by a.actor_id
            order by f.release_year
        ) as gap_years
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    join film f on fa.film_id = f.film_id
) t
group by actor_id, actor_name
order by biggest_gap_years desc;


-- cte-based solution
-- improves readability and reusability
with gaps as (
    select 
        a.actor_id,
        concat(a.first_name, ' ', a.last_name) as actor_name,
        f.release_year -
        lag(f.release_year) over (
            partition by a.actor_id
            order by f.release_year
        ) as gap_years
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    join film f on fa.film_id = f.film_id
)
select 
    actor_id,
    actor_name,
    max(gap_years) as biggest_gap_years
from gaps
group by actor_id, actor_name
order by biggest_gap_years desc;
