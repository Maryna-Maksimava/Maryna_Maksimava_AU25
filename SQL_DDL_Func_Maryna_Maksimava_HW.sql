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
SELECT * FROM public.sales_revenue_by_category_qtr

-----------------------------2

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(
    p_year INT,
    p_quarter INT
)
RETURNS TABLE (
    category TEXT,
    total_revenue NUMERIC
)
LANGUAGE sql
AS $$
    SELECT 
        c.name AS category,
        SUM(p.amount) AS total_revenue
    FROM public.payment p
    JOIN public.rental r ON p.rental_id = r.rental_id
    JOIN public.inventory i ON r.inventory_id = i.inventory_id
    JOIN public.film_category fc ON i.film_id = fc.film_id
    JOIN public.category c ON fc.category_id = c.category_id
    WHERE 
        DATE_PART('year', p.payment_date) = p_year
        AND DATE_PART('quarter', p.payment_date) = p_quarter
    GROUP BY c.name
    HAVING SUM(p.amount) > 0;
$$;

--------------------------------------------3
CREATE OR REPLACE FUNCTION public.most_popular_film_by_country(p_country TEXT)
RETURNS TABLE (
    country TEXT,
    film_title TEXT,
    rental_count BIGINT
)
LANGUAGE plpgsql AS
$$
BEGIN
    RETURN QUERY
    SELECT 
        c.country,
        f.title AS film_title,
        COUNT(r.rental_id) AS rental_count
    FROM country c
    JOIN city ci        ON ci.country_id = c.country_id
    JOIN address a      ON a.city_id = ci.city_id
    JOIN customer cu    ON cu.address_id = a.address_id
    JOIN rental r       ON r.customer_id = cu.customer_id
    JOIN inventory i    ON i.inventory_id = r.inventory_id
    JOIN film f         ON f.film_id = i.film_id
    WHERE c.country = p_country
    GROUP BY c.country, f.title
    ORDER BY rental_count DESC
    LIMIT 1;
END;
$$;
SELECT * 
FROM public.most_popular_film_by_country('Afghanistan'
);
------------------------------4
CREATE OR REPLACE FUNCTION public.films_in_stock_by_title(p_pattern TEXT)
RETURNS TABLE (
    row_num INT,
    film_id INT,
    title TEXT,
    store_id INT,
    inventory_id INT
)
LANGUAGE plpgsql AS
$$
BEGIN
    RETURN QUERY
    WITH films AS (
        SELECT 
            f.film_id       AS f_film_id,
            f.title         AS f_title,
            i.store_id      AS f_store_id,
            i.inventory_id  AS f_inventory_id,
            ROW_NUMBER() OVER (ORDER BY f.title) AS rn
        FROM film f
        JOIN inventory i ON i.film_id = f.film_id
        WHERE f.title ILIKE p_pattern
    )
    SELECT 
        rn AS row_num,
        f_film_id AS film_id,
        f_title AS title,
        f_store_id AS store_id,
        f_inventory_id AS inventory_id
    FROM films;

    IF NOT FOUND THEN
        RAISE NOTICE 'No films found in stock matching pattern: %', p_pattern;
    END IF;
END;
$$;
----------------------------5
CREATE OR REPLACE FUNCTION public.new_movie(
    p_title TEXT,
    p_release_year INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    p_language_name TEXT DEFAULT 'Klingon'
)
RETURNS VOID
LANGUAGE plpgsql
AS
$$
DECLARE
    v_language_id INT;
    v_film_id INT;
BEGIN
    -- 1. Validate language exists
    SELECT language_id INTO v_language_id
    FROM language
    WHERE name = p_language_name;

    IF v_language_id IS NULL THEN
        RAISE EXCEPTION 'Language "%" does not exist in the language table.', p_language_name;
    END IF;

    -- 2. Generate film_id
    SELECT COALESCE(MAX(film_id), 0) + 1 INTO v_film_id
    FROM film;

    -- 3. Insert new film
    INSERT INTO film (
        film_id, title, release_year, language_id,
        rental_duration, rental_rate, replacement_cost
    )
    VALUES (
        v_film_id,
        p_title,
        p_release_year,
        v_language_id,
        3,            -- rental duration
        4.99,         -- rental rate
        19.99         -- replacement cost
    );

    RAISE NOTICE 'New film "%" added with film_id %.', p_title, v_film_id;
END;
$$;
