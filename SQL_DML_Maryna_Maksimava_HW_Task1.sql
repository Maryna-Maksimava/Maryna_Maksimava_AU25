--------------------

INSERT INTO public.film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update)
SELECT 'Girl', 'A young transgender girl pursues her dream of becoming a ballerina.', 2018, l.language_id, 1, 4.99, 105, 19.99, 'R', current_date
FROM public.language l
WHERE l.name = 'English'
AND NOT EXISTS (SELECT 1 FROM public.film WHERE title = 'Girl')
RETURNING film_id;

INSERT INTO public.film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update)
SELECT 'Nymphomaniac: Volumes I & II', 'A self-diagnosed nymphomaniac recounts her erotic experiences.', 2013, l.language_id, 2, 9.99, 241, 19.99, 'NC-17', current_date
FROM public.language l
WHERE l.name = 'English'
AND NOT EXISTS (SELECT 1 FROM public.film WHERE title = 'Nymphomaniac: Volumes I & II')
RETURNING film_id;

INSERT INTO public.film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update)
SELECT 'Inception', 'A thief who steals corporate secrets through dreams is given the inverse task of planting an idea.', 2010, l.language_id, 3, 19.99, 148, 19.99, 'PG-13', current_date
FROM public.language l
WHERE l.name = 'English'
AND NOT EXISTS (SELECT 1 FROM public.film WHERE title = 'Inception')
RETURNING film_id;

COMMIT;

---------------------------------------------------------

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Victor', 'Polster', current_date
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name='Victor' AND last_name='Polster')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Charlotte', 'Gainsbourg', current_date
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name='Charlotte' AND last_name='Gainsbourg')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Stellan', 'Skarsgard', current_date
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name='Stellan' AND last_name='Skarsgard')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Leonardo', 'DiCaprio', current_date
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name='Leonardo' AND last_name='DiCaprio')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Joseph', 'Gordon-Levitt', current_date
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name='Joseph' AND last_name='Gordon-Levitt')
RETURNING actor_id;

INSERT INTO public.actor (first_name, last_name, last_update)
SELECT 'Elliot', 'Page', current_date
WHERE NOT EXISTS (SELECT 1 FROM public.actor WHERE first_name='Elliot' AND last_name='Page')
RETURNING actor_id;

COMMIT;
 
-----------------------------------------------------
INSERT INTO public.film_actor (film_id, actor_id, last_update)
SELECT f.film_id, a.actor_id, current_date
FROM public.film f
JOIN public.actor a ON (
  (f.title = 'Girl' AND a.first_name = 'Victor' AND a.last_name = 'Polster')
  OR (f.title = 'Nymphomaniac: Volumes I & II' AND a.first_name IN ('Charlotte','Stellan'))
  OR (f.title = 'Inception' AND a.first_name IN ('Leonardo','Joseph','Elliot'))
)
WHERE NOT EXISTS (
  SELECT 1 FROM public.film_actor fa WHERE fa.film_id = f.film_id AND fa.actor_id = a.actor_id
);

COMMIT;

----------------------------------------------------------------

INSERT INTO public.inventory (film_id, store_id, last_update)
SELECT f.film_id, 1, current_date
FROM public.film f
WHERE f.title IN ('Girl', 'Nymphomaniac: Volumes I & II', 'Inception')
AND NOT EXISTS (SELECT 1 FROM public.inventory i WHERE i.film_id = f.film_id AND i.store_id = 1)
RETURNING inventory_id;

COMMIT;
-------------------------------------

UPDATE public.customer
SET first_name = 'Maryna',
    last_name = 'Maksimava',
    email = 'maryna.maksimava@gmail.com',
    address_id = (SELECT address_id FROM public.address LIMIT 1),
    last_update = current_date
WHERE customer_id = (
    SELECT customer_id FROM (
        SELECT c.customer_id
        FROM public.customer c
        JOIN public.rental r ON c.customer_id = r.customer_id
        JOIN public.payment p ON c.customer_id = p.customer_id
        GROUP BY c.customer_id
        HAVING COUNT(DISTINCT r.rental_id) >= 43 AND COUNT(DISTINCT p.payment_id) >= 43
        LIMIT 1
    ) t
)
RETURNING customer_id;

COMMIT;
-------------------------------------------------------

DELETE FROM public.payment
WHERE customer_id IN (SELECT customer_id FROM public.customer WHERE first_name='Maryna' AND last_name='Maksimava');

DELETE FROM public.rental
WHERE customer_id IN (SELECT customer_id FROM public.customer WHERE first_name='Maryna' AND last_name='Maksimava');

COMMIT;
-----------------------------------------------
 
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT NOW(), i.inventory_id, c.customer_id, NOW() + INTERVAL '7 days', s.staff_id, current_date
FROM public.inventory i
JOIN public.film f ON i.film_id = f.film_id
JOIN public.customer c ON c.first_name='Maryna' AND c.last_name='Maksimava'
JOIN public.staff s ON s.store_id = i.store_id
WHERE f.title IN ('Girl', 'Nymphomaniac: Volumes I & II', 'Inception')
AND NOT EXISTS (
  SELECT 1 FROM public.rental r WHERE r.customer_id = c.customer_id AND r.inventory_id = i.inventory_id
)
RETURNING rental_id;
 
INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date, last_update)
SELECT c.customer_id, s.staff_id, r.rental_id, f.rental_rate, NOW(), current_date
FROM public.rental r
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film f ON i.film_id = f.film_id
JOIN public.customer c ON r.customer_id = c.customer_id
JOIN public.staff s ON r.staff_id = s.staff_id
WHERE f.title IN ('Girl', 'Nymphomaniac: Volumes I & II', 'Inception')
AND NOT EXISTS (
  SELECT 1 FROM public.payment p WHERE p.rental_id = r.rental_id
);

COMMIT;


