--1
---------------------------------
SELECT DISTINCT TITLE FROM FILM AS F
JOIN FILM_CATEGORY AS FC
ON FC.FILM_ID=FC.FILM_ID
JOIN CATEGORY AS C
ON C.CATEGORY_ID=FC.CATEGORY_ID
WHERE C.NAME ILIKE 'animation'
ORDER BY TITLE


--------------------------------------------------

SELECT    s.store_id, CONCAT(a.address, ', ', COALESCE(a.address2, '')) AS full_address, SUM(p.amount) AS revenue
FROM payment p
JOIN rental AS r ON p.rental_id = r.rental_id
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN store AS s ON i.store_id = s.store_id
JOIN address AS a ON s.address_id = a.address_id
WHERE p.payment_date >= '2017-04-01'
GROUP BY s.store_id, a.address, a.address2
ORDER BY revenue DESC

-------------------------------------------------------

SELECT first_name, last_name, COUNT(F.FILM_ID) AS number_of_movies
FROM ACTOR AS A JOIN FILM_ACTOR AS FA
	ON FA.ACTOR_ID=A.ACTOR_ID
JOIN FILM AS F
	ON F.FILM_ID=FA.FILM_ID
WHERE F.RELEASE_YEAR>2015
	GROUP BY A.ACTOR_ID
ORDER BY number_of_movies DESC

-------------------------------------------
SELECT 
    f.release_year,
    COUNT(CASE WHEN c.name = 'Drama' THEN 1 END) AS number_of_drama_movies,
    COUNT(CASE WHEN c.name = 'Travel' THEN 1 END) AS number_of_travel_movies,
    COUNT(CASE WHEN c.name = 'Documentary' THEN 1 END) AS number_of_documentary_movies
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
GROUP BY f.release_year
ORDER BY f.release_year DESC;



----------------------------------
--2
------------------------------------------------
WITH staff_revenue_2017 AS (
    SELECT 
        p.staff_id,
        s.first_name,
        s.last_name,
        i.store_id,
        SUM(p.amount) AS total_revenue,
        MAX(p.payment_date) AS last_payment_date
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN staff s ON p.staff_id = s.staff_id
    WHERE p.payment_date BETWEEN '2017-01-01' AND '2017-12-31'
    GROUP BY p.staff_id, s.first_name, s.last_name, i.store_id
),
latest_store AS (
    SELECT DISTINCT ON (staff_id)
        staff_id,
        store_id
    FROM staff_revenue_2017
    ORDER BY staff_id, last_payment_date DESC
),
total_revenue_2017 AS (
    SELECT 
        p.staff_id,
        SUM(p.amount) AS total_revenue
    FROM payment p
    WHERE p.payment_date BETWEEN '2017-01-01' AND '2017-12-31'
    GROUP BY p.staff_id
)
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    ls.store_id,
    CONCAT(a.address, ', ', COALESCE(a.address2, '')) AS store_address,
    ROUND(tr.total_revenue, 2) AS total_revenue
FROM latest_store ls
JOIN staff s ON ls.staff_id = s.staff_id
JOIN store st ON ls.store_id = st.store_id
JOIN address a ON st.address_id = a.address_id
JOIN total_revenue_2017 tr ON s.staff_id = tr.staff_id
ORDER BY total_revenue DESC
LIMIT 3;


------------------------------------------
SELECT 
    f.film_id,
    f.title,
    f.rating,
    COUNT(r.rental_id) AS rental_count,
    CASE f.rating
        WHEN 'G' THEN 'All Ages'
        WHEN 'PG' THEN 'Parental Guidance (8+)'
        WHEN 'PG-13' THEN 'Teens (13+)'
        WHEN 'R' THEN 'Adults (17+)'
        WHEN 'NC-17' THEN 'Adults Only (18+)'
        ELSE 'Unrated/Unknown'
    END AS expected_audience_age
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title, f.rating
ORDER BY rental_count DESC
LIMIT 5;

------------------
--3
-------------
SELECT 
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    MAX(f.release_year) AS last_release_year,
    EXTRACT(YEAR FROM CURRENT_DATE) - MAX(f.release_year) AS inactivity_years
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY a.actor_id, actor_name
ORDER BY inactivity_years DESC;


-------------------------
SELECT 
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    f.release_year,
    LAG(f.release_year) OVER (PARTITION BY a.actor_id ORDER BY f.release_year) AS previous_year,
    f.release_year - LAG(f.release_year) OVER (PARTITION BY a.actor_id ORDER BY f.release_year) AS gap_years
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
ORDER BY a.actor_id, f.release_year;
