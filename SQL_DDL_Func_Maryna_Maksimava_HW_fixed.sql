----------------------------1
CREATE OR REPLACE VIEW public.sales_revenue_by_category_qtr AS
WITH current_period AS (
    SELECT
        DATE_PART('year', CURRENT_DATE)::int AS curr_year,
        DATE_PART('quarter', CURRENT_DATE)::int AS curr_qtr
)
SELECT 
    c.name AS category,
    SUM(p.amount) AS total_revenue
FROM public.payment p
JOIN public.rental r ON p.rental_id = r.rental_id
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film_category fc ON i.film_id = fc.film_id
JOIN public.category c ON fc.category_id = c.category_id
CROSS JOIN current_period cp
WHERE 
    DATE_PART('year', p.payment_date) = cp.curr_year
    AND DATE_PART('quarter', p.payment_date) = cp.curr_qtr
GROUP BY c.name
HAVING SUM(p.amount) > 0;
SELECT * FROM public.sales_revenue_by_category_qtr;

-----------------------------2

-- returns sales revenue by category
-- for the quarter derived from the provided date

create or replace function public.get_sales_revenue_by_category_qtr(
    p_date date
)
returns table (
    category text,
    total_revenue numeric
)
language sql
as $$
    select
        c.name as category,
        sum(p.amount) as total_revenue
    from payment p
    join rental r on p.rental_id = r.rental_id
    join inventory i on r.inventory_id = i.inventory_id
    join film_category fc on i.film_id = fc.film_id
    join category c on fc.category_id = c.category_id
    where date_part('year', p.payment_date) = date_part('year', p_date)
      and date_part('quarter', p.payment_date) = date_part('quarter', p_date)
    group by c.name
    having sum(p.amount) > 0;
$$;


-- call
select * from public.get_sales_revenue_by_category_qtr('2024-01-15');
select * from public.get_sales_revenue_by_category_qtr(current_date);
select * from public.get_sales_revenue_by_category_qtr(date '2023-11-01');


--------------------------------------------3
-- returns most popular film per country (array input)
-- case-insensitive
-- raises notice if a country has no rental data

create or replace function public.most_popular_film_by_country(
    p_countries text[]
)
returns table (
    country text,
    film_title text,
    rental_count bigint
)
language plpgsql
as $$
declare
    v_country text;
begin
    foreach v_country in array p_countries loop

        return query
        select
            c.country,
            f.title as film_title,
            count(r.rental_id) as rental_count
        from country c
        join city ci on ci.country_id = c.country_id
        join address a on a.city_id = ci.city_id
        join customer cu on cu.address_id = a.address_id
        join rental r on r.customer_id = cu.customer_id
        join inventory i on i.inventory_id = r.inventory_id
        join film f on f.film_id = i.film_id
        where lower(c.country) = lower(v_country)
        group by c.country, f.title
        order by rental_count desc
        limit 1;

        if not found then
            raise notice 'no rental data found for country: %', v_country;
        end if;

    end loop;
end;
$$;

select *
from public.most_popular_film_by_country(
    array['Afghanistan', 'Brazil', 'Neverland']
);

------------------------------4
-- returns films currently in stock filtered by title pattern
-- distinct by film
-- uses latest rental date
-- schema types aligned (store_id smallint, rental_date timestamptz)

create or replace function public.films_in_stock_by_title(
    p_pattern text
)
returns table (
    film_id int,
    title text,
    store_id smallint,
    latest_rental_date timestamptz
)
language plpgsql
as $$
begin
    return query
    select
        f.film_id,
        f.title,
        i.store_id,
        max(r.rental_date) as latest_rental_date
    from film f
    join inventory i on i.film_id = f.film_id
    join rental r on r.inventory_id = i.inventory_id
    where f.title ilike p_pattern
      and r.return_date is not null
    group by f.film_id, f.title, i.store_id;

    if not found then
        raise notice 'no films in stock matching pattern: %', p_pattern;
    end if;
end;
$$;

-- call
select *
from public.films_in_stock_by_title('%Inception%');

----------------------------5
-- inserts a new movie
-- auto-creates language if not exists
-- prevents duplicate titles

create or replace function public.new_movie(
    p_title text,
    p_release_year int default extract(year from current_date),
    p_language_name text default 'Klingon'
)
returns void
language plpgsql
as $$
declare
    v_language_id int;
begin
    -- handle duplicates
    if exists (
        select 1 from film where lower(title) = lower(p_title)
    ) then
        raise notice 'film "%" already exists, skipping insert', p_title;
        return;
    end if;

    -- ensure language exists
    select language_id
    into v_language_id
    from language
    where lower(name) = lower(p_language_name);

    if v_language_id is null then
        insert into language (name, last_update)
        values (p_language_name, current_date)
        returning language_id into v_language_id;

        raise notice 'language "%" created', p_language_name;
    end if;

    -- insert film (film_id auto-generated)
    insert into film (
        title,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        replacement_cost
    )
    values (
        p_title,
        p_release_year,
        v_language_id,
        3,
        4.99,
        19.99
    );

    raise notice 'new film "%" successfully added', p_title;
end;
$$;

-- default language (klingon will be auto-created)
select public.new_movie('Interstellar');

-- explicit language
select public.new_movie('Dune', 2021, 'English');

-- duplicate test
select public.new_movie('Inception');

