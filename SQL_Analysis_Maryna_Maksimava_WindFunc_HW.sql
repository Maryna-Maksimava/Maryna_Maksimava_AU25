--1

WITH customer_channel_sales AS (
    SELECT
        s.channel_id,
        s.cust_id,
        SUM(s.amount_sold) AS amount_sold
    FROM sh.sales s
    GROUP BY s.channel_id, s.cust_id
),
channel_totals AS (
    SELECT
        channel_id,
        SUM(amount_sold) AS total_channel_sales
    FROM customer_channel_sales
    GROUP BY channel_id
),
ranked_customers AS (
    SELECT
        ccs.channel_id,
        ccs.cust_id,
        ccs.amount_sold,
        ct.total_channel_sales,
        RANK() OVER (
            PARTITION BY ccs.channel_id
            ORDER BY ccs.amount_sold DESC
        ) AS sales_rank
    FROM customer_channel_sales ccs
    JOIN channel_totals ct
        ON ccs.channel_id = ct.channel_id
)
SELECT
    ch.channel_desc,
    cu.cust_last_name,
    cu.cust_first_name,
    ROUND(rc.amount_sold, 2) AS amount_sold,
    ROUND(
        (rc.amount_sold / rc.total_channel_sales) * 100,
        4
    ) || '%' AS sales_percentage
FROM ranked_customers rc
JOIN sh.channels ch
    ON rc.channel_id = ch.channel_id
JOIN sh.customers cu
    ON rc.cust_id = cu.cust_id
WHERE rc.sales_rank <= 5
ORDER BY
    ch.channel_desc,
    rc.amount_sold DESC;




---2
WITH base AS (
    SELECT
        p.prod_name AS product_name,
        t.calendar_quarter_number AS q,
        SUM(s.amount_sold) AS amt
    FROM sh.sales s
    JOIN sh.products p
        ON s.prod_id = p.prod_id
    JOIN sh.customers c
        ON s.cust_id = c.cust_id
    JOIN sh.countries co
        ON c.country_id = co.country_id
    JOIN sh.times t
        ON s.time_id = t.time_id
    WHERE p.prod_category = 'Photo'
      AND co.country_region = 'Asia'
      AND t.calendar_year = 2000
    GROUP BY p.prod_name, t.calendar_quarter_number
)
SELECT
    product_name,
    ROUND(COALESCE(SUM(amt) FILTER (WHERE q = 1), 0), 2) AS q1,
    ROUND(COALESCE(SUM(amt) FILTER (WHERE q = 2), 0), 2) AS q2,
    ROUND(COALESCE(SUM(amt) FILTER (WHERE q = 3), 0), 2) AS q3,
    ROUND(COALESCE(SUM(amt) FILTER (WHERE q = 4), 0), 2) AS q4,
    ROUND(SUM(amt), 2) AS year_sum
FROM base
GROUP BY product_name
ORDER BY product_name ASC;


--3
WITH yearly_customer_sales AS (
    SELECT
        s.channel_id,
        s.cust_id,
        t.calendar_year,
        SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.times t
        ON s.time_id = t.time_id
    WHERE t.calendar_year IN (1998, 1999, 2001)
    GROUP BY s.channel_id, s.cust_id, t.calendar_year
),
ranked_customers AS (
    SELECT
        ycs.channel_id,
        ycs.cust_id,
        ycs.calendar_year,
        ycs.total_sales,
        RANK() OVER (
            PARTITION BY ycs.channel_id, ycs.calendar_year
            ORDER BY ycs.total_sales DESC
        ) AS sales_rank
    FROM yearly_customer_sales ycs
),
top_300_per_year AS (
    SELECT *
    FROM ranked_customers
    WHERE sales_rank <= 300
),
customers_in_all_years AS (
    SELECT
        channel_id,
        cust_id
    FROM top_300_per_year
    GROUP BY channel_id, cust_id
    HAVING COUNT(DISTINCT calendar_year) = 3
)
SELECT
    ch.channel_desc,
    cu.cust_id,
    cu.cust_last_name,
    cu.cust_first_name,
    ROUND(SUM(t300.total_sales), 2) AS amount_sold
FROM top_300_per_year t300
JOIN customers_in_all_years cay
    ON t300.channel_id = cay.channel_id
   AND t300.cust_id = cay.cust_id
JOIN sh.channels ch
    ON t300.channel_id = ch.channel_id
JOIN sh.customers cu
    ON t300.cust_id = cu.cust_id
GROUP BY
    ch.channel_desc,
    cu.cust_id,
    cu.cust_last_name,
    cu.cust_first_name
ORDER BY
    ch.channel_desc,
    amount_sold DESC;

--4
SELECT
    t.calendar_month_desc,
    p.prod_category,
    ROUND(
        SUM(CASE WHEN co.country_region = 'Americas'
                 THEN s.amount_sold ELSE 0 END),
        2
    ) AS "Americas SALES",
    ROUND(
        SUM(CASE WHEN co.country_region = 'Europe'
                 THEN s.amount_sold ELSE 0 END),
        2
    ) AS "Europe SALES"
FROM sh.sales s
JOIN sh.times t
    ON s.time_id = t.time_id
JOIN sh.products p
    ON s.prod_id = p.prod_id
JOIN sh.customers c
    ON s.cust_id = c.cust_id
JOIN sh.countries co
    ON c.country_id = co.country_id
WHERE t.calendar_year = 2000
  AND t.calendar_month_number IN (1, 2, 3)
  AND co.country_region IN ('Americas', 'Europe')
GROUP BY
    t.calendar_month_desc,
    t.calendar_month_number,
    p.prod_category
ORDER BY
    t.calendar_month_number,
    p.prod_category;
