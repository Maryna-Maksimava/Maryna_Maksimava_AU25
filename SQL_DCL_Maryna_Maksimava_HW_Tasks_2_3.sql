--2
-- 1-----------------------
--create login user rentaluser with password 'rentalpassword'
-- -----------------------
do $$
begin
    if not exists (select 1 from pg_catalog.pg_roles r where r.rolname = 'rentaluser') then
        create user rentaluser with password 'rentalpassword';
    end if;
end $$;
 
-- allow connect 
grant connect on database dvdrental to rentaluser;

-- grant select on customer table
grant select on table public.customer to rentaluser;
--2


SET ROLE rentaluser;
--test role
SELECT * FROM customer LIMIT 5;
--get back to postgres to create roles
SET ROLE postgres;

--3	
do $$
begin
    -- create role if it does not exist
    if not exists (
        select 1
        from pg_catalog.pg_roles
        where rolname = 'rental'
    ) then
        create role rental;
    end if;

    -- grant role to rentaluser if not already a member
    if not exists (
        select 1
        from pg_catalog.pg_auth_members m
        join pg_catalog.pg_roles r on r.oid = m.roleid
        join pg_catalog.pg_roles u on u.oid = m.member
        where r.rolname = 'rental'
          and u.rolname = 'rentaluser'
    ) then
        grant rental to rentaluser;
    end if;
end $$;

--4
GRANT INSERT, UPDATE ON rental TO rental;
--Test INSERT/UPDATE:
set role rentaluser;
insert into public.rental (
    rental_date,
    inventory_id,
    customer_id,
    staff_id,
    last_update
)
select
    now(),
    (select i.inventory_id
     from public.inventory i
     order by i.inventory_id asc
     limit 1),
    (select c.customer_id
     from public.customer c
     where exists (select 1 from public.rental r where r.customer_id = c.customer_id)
       and exists (select 1 from public.payment p where p.customer_id = c.customer_id)
     order by c.customer_id
     limit 1),
    (select s.staff_id
     from public.staff s
     order by s.staff_id
     limit 1),
    current_timestamp
returning rental_id;

update public.rental
set last_update = current_timestamp
where rental_id = (
    select r.rental_id
    from public.rental r
    order by r.rental_id asc
    limit 1
);

--5
set role postgres;
REVOKE INSERT ON rental FROM rental;
-- test INSERT and it fails
SET ROLE rental;
insert into public.rental (
    rental_date,
    inventory_id,
    customer_id,
    staff_id,
    last_update
)
select
    now(),
    (select i.inventory_id
     from public.inventory i
     order by i.inventory_id desc
     limit 1),
    (select c.customer_id
     from public.customer c
     where exists (select 1 from public.rental r where r.customer_id = c.customer_id)
       and exists (select 1 from public.payment p where p.customer_id = c.customer_id)
     order by c.customer_id
     limit 1),
    (select s.staff_id
     from public.staff s
     order by s.staff_id
     limit 1),
    current_timestamp
returning rental_id;	
--6

do $$
declare
    v_first_name text := 'Betty';
    v_last_name  text := 'White';
    v_customer_id int;
    v_role_name text;
begin
    -- 1) locate customer id by name
    select c.customer_id
    into v_customer_id
    from public.customer c
    where c.first_name ilike v_first_name
      and c.last_name ilike v_last_name
    order by c.customer_id
    limit 1;

    if v_customer_id is null then
        raise exception 'customer %.% not found in public.customer', v_first_name, v_last_name;
    end if;

    -- 2) enforce requirement: customer must have BOTH rental and payment history
    if not exists (select 1 from public.rental r where r.customer_id = v_customer_id) then
        raise exception 'customer %.% (customer_id=%) has no rental history', v_first_name, v_last_name, v_customer_id;
    end if;

    if not exists (select 1 from public.payment p where p.customer_id = v_customer_id) then
        raise exception 'customer %.% (customer_id=%) has no payment history', v_first_name, v_last_name, v_customer_id;
    end if;

    -- 3) create role name 
    v_role_name := lower(format('client_%s_%s', v_first_name, v_last_name));


    -- 4) create role if not exists 
    if not exists (select 1 from pg_catalog.pg_roles r where r.rolname = v_role_name) then
        execute format('create role %I', v_role_name);
    end if;

    -- 5) store the customer_id in a role-level setting 
    execute format('alter role %I set app.customer_id = %L', v_role_name, v_customer_id::text);

    -- 6) grant permissions 
    execute format('grant connect on database dvdrental to %I', v_role_name);
    execute format('grant select on table public.rental to %I', v_role_name);
    execute format('grant select on table public.payment to %I', v_role_name);

    raise notice 'created/updated role %, mapped to customer_id=%', v_role_name, v_customer_id;
end $$;


--Task_3


alter table public.rental  enable row level security;
alter table public.payment enable row level security;

-- drop policies if they already exist
drop policy if exists rental_rls_by_customer on public.rental;
drop policy if exists payment_rls_by_customer on public.payment;

create policy rental_rls_by_customer
on public.rental
for select
to public
using (
    customer_id = nullif(current_setting('app.customer_id', true), '')::int
);

create policy payment_rls_by_customer
on public.payment
for select
to public
using (
    customer_id = nullif(current_setting('app.customer_id', true), '')::int
);

set role client_Betty_White;

SELECT * FROM rental;
SELECT * FROM payment;
reset role;
