--------------------

insert into public.film (
    title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update
)
select
    'Girl',
    'A young transgender girl pursues her dream of becoming a ballerina.',
    2018,
    l.language_id,
    1,
    4.99,
    105,
    19.99,
    'R',
    current_date
from public.language l
where l.name = 'English'
and not exists (
    select 1
    from public.film
    where title = 'Girl'
)
returning film_id;

insert into public.film (
    title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update
)
select
    'Nymphomaniac: Volumes I & II',
    'A self-diagnosed nymphomaniac recounts her erotic experiences.',
    2013,
    l.language_id,
    2,
    9.99,
    241,
    19.99,
    'NC-17',
    current_date
from public.language l
where l.name = 'English'
and not exists (
    select 1
    from public.film
    where title = 'Nymphomaniac: Volumes I & II'
)
returning film_id;

insert into public.film (
    title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update
)
select
    'Inception',
    'A thief who steals corporate secrets through dreams is given the inverse task of planting an idea.',
    2010,
    l.language_id,
    3,
    19.99,
    148,
    19.99,
    'PG-13',
    current_date
from public.language l
where l.name = 'English'
and not exists (
    select 1
    from public.film
    where title = 'Inception'
);

commit;

---------------------------------------------------------

insert into public.actor (first_name, last_name, last_update)
select 'Victor', 'Polster', current_date
where not exists (
    select 1
    from public.actor
    where first_name = 'Victor'
      and last_name = 'Polster'
)
returning actor_id;

insert into public.actor (first_name, last_name, last_update)
select 'Charlotte', 'Gainsbourg', current_date
where not exists (
    select 1
    from public.actor
    where first_name = 'Charlotte'
      and last_name = 'Gainsbourg'
)
returning actor_id;

insert into public.actor (first_name, last_name, last_update)
select 'Stellan', 'Skarsgard', current_date
where not exists (
    select 1
    from public.actor
    where first_name = 'Stellan'
      and last_name = 'Skarsgard'
)
returning actor_id;

insert into public.actor (first_name, last_name, last_update)
select 'Leonardo', 'DiCaprio', current_date
where not exists (
    select 1
    from public.actor
    where first_name = 'Leonardo'
      and last_name = 'DiCaprio'
)
returning actor_id;

insert into public.actor (first_name, last_name, last_update)
select 'Joseph', 'Gordon-Levitt', current_date
where not exists (
    select 1
    from public.actor
    where first_name = 'Joseph'
      and last_name = 'Gordon-Levitt'
)
returning actor_id;

insert into public.actor (first_name, last_name, last_update)
select 'Elliot', 'Page', current_date
where not exists (
    select 1
    from public.actor
    where first_name = 'Elliot'
      and last_name = 'Page'
)
returning actor_id;

commit;

-----------------------------------------------------

insert into public.film_actor (film_id, actor_id, last_update)
select
    f.film_id,
    a.actor_id,
    current_date
from public.film f
join public.actor a on (
    (f.title = 'Girl' and a.first_name = 'Victor' and a.last_name = 'Polster')
    or (f.title = 'Nymphomaniac: Volumes I & II' and a.first_name in ('Charlotte', 'Stellan'))
    or (f.title = 'Inception' and a.first_name in ('Leonardo', 'Joseph', 'Elliot'))
)
where not exists (
    select 1
    from public.film_actor fa
    where fa.film_id = f.film_id
      and fa.actor_id = a.actor_id
);

commit;

----------------------------------------------------------------

insert into public.inventory (film_id, store_id, last_update)
select
    f.film_id,
    1,
    current_date
from public.film f
where f.title in ('Girl', 'Nymphomaniac: Volumes I & II', 'Inception')
and not exists (
    select 1
    from public.inventory i
    where i.film_id = f.film_id
      and i.store_id = 1
)
returning inventory_id;

commit;

-------------------------------------

update public.customer
set first_name = 'Maryna',
    last_name = 'Maksimava',
    email = 'maryna.maksimava@gmail.com',
    address_id = (select address_id from public.address limit 1),
    last_update = current_date
where customer_id = (
    select customer_id
    from (
        select c.customer_id
        from public.customer c
        join public.rental r on c.customer_id = r.customer_id
        join public.payment p on c.customer_id = p.customer_id
        group by c.customer_id
        having count(distinct r.rental_id) >= 43
           and count(distinct p.payment_id) >= 43
        limit 1
    ) t
)
returning customer_id;

commit;

-------------------------------------------------------

delete from public.payment
where customer_id in (
    select customer_id
    from public.customer
    where first_name = 'Maryna'
      and last_name = 'Maksimava'
);

delete from public.rental
where customer_id in (
    select customer_id
    from public.customer
    where first_name = 'Maryna'
      and last_name = 'Maksimava'
);

commit;

-----------------------------------------------

-- insert rentals (fixed)
insert into public.rental (
    rental_date,
    inventory_id,
    customer_id,
    return_date,
    staff_id,
    last_update
)
select
    now(),
    i.inventory_id,
    c.customer_id,
    now() + interval '7 days',
    s.staff_id,
    current_date
from public.inventory i
join public.film f
    on i.film_id = f.film_id
join public.customer c
    on c.first_name = 'Maryna'
   and c.last_name = 'Maksimava'
join (
    select distinct on (store_id)
        store_id,
        staff_id
    from public.staff
    order by store_id, staff_id
) s
    on s.store_id = i.store_id
where f.title in ('Girl', 'Nymphomaniac: Volumes I & II', 'Inception')
and not exists (
    select 1
    from public.rental r
    where r.customer_id = c.customer_id
      and r.inventory_id = i.inventory_id
)
returning rental_id;

commit;

-------------------------------------------------------

-- create partition for current year payments
create table if not exists public.payment_2025
partition of public.payment
for values from ('2025-01-01') to ('2026-01-01');

-- insert payments (fixed)
insert into public.payment (
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
)
select
    c.customer_id,
    r.staff_id,
    r.rental_id,
    f.rental_rate,
    now()
from public.rental r
join public.inventory i
    on r.inventory_id = i.inventory_id
join public.film f
    on i.film_id = f.film_id
join public.customer c
    on r.customer_id = c.customer_id
where f.title in ('Girl', 'Nymphomaniac: Volumes I & II', 'Inception')
and not exists (
    select 1
    from public.payment p
    where p.rental_id = r.rental_id
);

commit;
