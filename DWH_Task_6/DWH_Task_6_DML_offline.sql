SET search_path TO BL_3NF;

-------------
BEGIN;
LOCK TABLE LKP_CHANNELS IN EXCLUSIVE MODE;

INSERT INTO LKP_CHANNELS (
    channel_id, channel_name, ta_insert_dt, source_system, source_entity, source_channel_id
)
SELECT
    COALESCE((SELECT MAX(channel_id) FROM LKP_CHANNELS), 0) + 1,
    'OFFLINE',
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'OFFLINE'
WHERE NOT EXISTS (
    SELECT 1 FROM LKP_CHANNELS t
    WHERE t.channel_name='OFFLINE'
      AND t.source_system='SA_OFFLINE'
      AND t.source_entity='SRC_OFFLINE_SALES'
);

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_COUNTRIES IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(x.country_name), ''), 'UNKNOWN') AS country_name
    FROM (
        SELECT customer_address_country AS country_name FROM sa_offline.src_offline_sales
        UNION ALL SELECT store_address_country FROM sa_offline.src_offline_sales
        UNION ALL SELECT cashier_address_country FROM sa_offline.src_offline_sales
        UNION ALL SELECT product_country_of_origin FROM sa_offline.src_offline_sales
    ) x
),
mx AS (SELECT COALESCE(MAX(country_id), 0) AS m FROM LKP_COUNTRIES),
n AS (
    SELECT
        (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.country_name) AS country_id,
        v.country_name
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_COUNTRIES t
        WHERE t.country_name=v.country_name
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_COUNTRIES (
    country_id, country_code, country_name, ta_insert_dt, source_system, source_entity, src_country_id
)
SELECT
    n.country_id,
    CASE WHEN LENGTH(n.country_name) >= 3 THEN UPPER(LEFT(n.country_name, 3)) ELSE UPPER(n.country_name) END,
    n.country_name,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.country_name
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_REGIONS IN EXCLUSIVE MODE;

WITH src AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(s.region_name), ''), 'UNKNOWN') AS region_name,
        COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN') AS country_name
    FROM (
        SELECT customer_address_region AS region_name, customer_address_country AS country_name FROM sa_offline.src_offline_sales
        UNION ALL SELECT store_address_region, store_address_country FROM sa_offline.src_offline_sales
        UNION ALL SELECT cashier_address_region, cashier_address_country FROM sa_offline.src_offline_sales
    ) s
),
r AS (
    SELECT DISTINCT
        src.region_name,
        c.country_id,
        ('SA_OFFLINE|SRC_OFFLINE_SALES|' || src.country_name || '|' || src.region_name) AS source_region_id
    FROM src
    JOIN LKP_COUNTRIES c
      ON c.country_name=src.country_name
     AND c.source_system='SA_OFFLINE'
     AND c.source_entity='SRC_OFFLINE_SALES'
),
mx AS (SELECT COALESCE(MAX(region_id), 0) AS m FROM LKP_REGIONS),
n AS (
    SELECT
        (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY r.country_id, r.region_name) AS region_id,
        r.*
    FROM r
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_REGIONS t
        WHERE t.region_name=r.region_name
          AND t.country_id=r.country_id
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_REGIONS (
    region_id, region_name, country_id, ta_insert_dt, source_system, source_entity, source_region_id
)
SELECT
    n.region_id,
    n.region_name,
    n.country_id,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    n.source_region_id
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_CITIES IN EXCLUSIVE MODE;

WITH src AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(s.city_name), ''), 'UNKNOWN') AS city_name,
        COALESCE(NULLIF(TRIM(s.region_name), ''), 'UNKNOWN') AS region_name,
        COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN') AS country_name
    FROM (
        SELECT customer_address_city AS city_name, customer_address_region AS region_name, customer_address_country AS country_name FROM sa_offline.src_offline_sales
        UNION ALL SELECT store_address_city, store_address_region, store_address_country FROM sa_offline.src_offline_sales
        UNION ALL SELECT cashier_address_city, cashier_address_region, cashier_address_country FROM sa_offline.src_offline_sales
    ) s
),
x AS (
    SELECT DISTINCT
        src.city_name,
        r.region_id,
        ('SA_OFFLINE|SRC_OFFLINE_SALES|' || src.country_name || '|' || src.region_name || '|' || src.city_name) AS source_city_id
    FROM src
    JOIN LKP_COUNTRIES c
      ON c.country_name=src.country_name
     AND c.source_system='SA_OFFLINE'
     AND c.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_REGIONS r
      ON r.country_id=c.country_id
     AND r.region_name=src.region_name
     AND r.source_system='SA_OFFLINE'
     AND r.source_entity='SRC_OFFLINE_SALES'
),
mx AS (SELECT COALESCE(MAX(city_id), 0) AS m FROM LKP_CITIES),
n AS (
    SELECT
        (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY x.region_id, x.city_name) AS city_id,
        x.*
    FROM x
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_CITIES t
        WHERE t.city_name=x.city_name
          AND t.region_id=x.region_id
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_CITIES (
    city_id, city_name, region_id, ta_insert_dt, source_system, source_entity, source_city_id
)
SELECT
    n.city_id,
    n.city_name,
    n.region_id,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    n.source_city_id
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_ADDRESSES IN EXCLUSIVE MODE;

WITH src AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN') AS country_name,
        COALESCE(NULLIF(TRIM(s.region_name), ''), 'UNKNOWN')  AS region_name,
        COALESCE(NULLIF(TRIM(s.city_name), ''), 'UNKNOWN')    AS city_name,
        COALESCE(NULLIF(TRIM(s.street), ''), 'UNKNOWN')       AS street,
        COALESCE(NULLIF(TRIM(s.house_number), ''), 'UNKNOWN') AS house_number,
        COALESCE(NULLIF(TRIM(s.apartment_number), ''), 'UNKNOWN') AS apartment_number,
        COALESCE(NULLIF(TRIM(s.postal_code), ''), 'UNKNOWN')  AS postal_code
    FROM (
        SELECT customer_address_country AS country_name, customer_address_region AS region_name, customer_address_city AS city_name,
               customer_address_street AS street, customer_address_house_number AS house_number,
               customer_address_apartment_number AS apartment_number, customer_address_postal_code AS postal_code
        FROM sa_offline.src_offline_sales
        UNION ALL
        SELECT store_address_country, store_address_region, store_address_city,
               store_address_street, store_address_house_number,
               store_address_apartment_number, store_address_postal_code
        FROM sa_offline.src_offline_sales
        UNION ALL
        SELECT cashier_address_country, cashier_address_region, cashier_address_city,
               cashier_address_street, cashier_address_house_number,
               cashier_address_apartment_number, cashier_address_postal_code
        FROM sa_offline.src_offline_sales
    ) s
),
a AS (
    SELECT DISTINCT
        src.street,
        src.house_number,
        src.apartment_number,
        src.postal_code,
        ci.city_id,
        ('SA_OFFLINE|SRC_OFFLINE_SALES|' ||
         src.country_name || '|' || src.region_name || '|' || src.city_name || '|' ||
         src.street || '|' || src.house_number || '|' || src.apartment_number || '|' || src.postal_code) AS source_address_id
    FROM src
    JOIN LKP_COUNTRIES c
      ON c.country_name=src.country_name
     AND c.source_system='SA_OFFLINE'
     AND c.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_REGIONS r
      ON r.country_id=c.country_id
     AND r.region_name=src.region_name
     AND r.source_system='SA_OFFLINE'
     AND r.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_CITIES ci
      ON ci.region_id=r.region_id
     AND ci.city_name=src.city_name
     AND ci.source_system='SA_OFFLINE'
     AND ci.source_entity='SRC_OFFLINE_SALES'
),
mx AS (SELECT COALESCE(MAX(address_id), 0) AS m FROM LKP_ADDRESSES),
n AS (
    SELECT
        (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY a.city_id, a.street, a.house_number, a.apartment_number, a.postal_code) AS address_id,
        a.*
    FROM a
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_ADDRESSES t
        WHERE t.city_id=a.city_id
          AND t.street=a.street
          AND t.house_number=a.house_number
          AND t.apartment_number=a.apartment_number
          AND t.postal_code=a.postal_code
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_ADDRESSES (
    address_id, street, house_number, apartment_number, postal_code, city_id,
    ta_insert_dt, source_entity, source_system, source_address_id
)
SELECT
    n.address_id,
    n.street,
    n.house_number,
    n.apartment_number,
    n.postal_code,
    n.city_id,
    CURRENT_TIMESTAMP,
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE',
    n.source_address_id
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_STORE_FORMATS IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(store_format), ''), 'UNKNOWN') AS store_format_name
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(store_format_id), 0) AS m FROM LKP_STORE_FORMATS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.store_format_name) AS store_format_id, v.store_format_name
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_STORE_FORMATS t
        WHERE t.store_format_name=v.store_format_name
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_STORE_FORMATS (
    store_format_id, store_format_name, ta_insert_dt, source_system, source_entity, source_store_format_id
)
SELECT
    n.store_format_id,
    n.store_format_name,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.store_format_name
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_ROLES IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(cashier_role), ''), 'UNKNOWN') AS role_name
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(role_id), 0) AS m FROM LKP_ROLES),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.role_name) AS role_id, v.role_name
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_ROLES t
        WHERE t.role_name=v.role_name
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_ROLES (
    role_id, role_name, ta_insert_dt, source_system, source_entity, source_role_id
)
SELECT
    n.role_id,
    n.role_name,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.role_name
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_SHIFTS IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(cashier_shift_code), ''), 'UNKNOWN') AS shift_name
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(shift_id), 0) AS m FROM LKP_SHIFTS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.shift_name) AS shift_id, v.shift_name
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_SHIFTS t
        WHERE t.shift_name=v.shift_name
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_SHIFTS (
    shift_id, shift_name, ta_insert_dt, source_system, source_entity, source_shift_id
)
SELECT
    n.shift_id,
    n.shift_name,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.shift_name
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_COMMUNICATION_CHANNELS IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(customer_preferred_communication_channel), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(communication_channel_id), 0) AS m FROM LKP_COMMUNICATION_CHANNELS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS communication_channel_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_COMMUNICATION_CHANNELS t
        WHERE t.communication_channel_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_COMMUNICATION_CHANNELS (
    communication_channel_id, communication_channel_name, ta_insert_dt, source_system, source_entity, source_communication_channel_id
)
SELECT
    n.communication_channel_id,
    n.nm,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_ORDER_STATUSES IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(order_status), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(order_status_id), 0) AS m FROM LKP_ORDER_STATUSES),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS order_status_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_ORDER_STATUSES t
        WHERE t.order_status_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_ORDER_STATUSES (
    order_status_id, order_status_name, ta_insert_dt, ta_update_dt, source_system, source_entity, source_status_id
)
SELECT
    n.order_status_id,
    n.nm,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_PAYMENT_METHODS IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(payment_method), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(payment_method_id), 0) AS m FROM LKP_PAYMENT_METHODS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS payment_method_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_PAYMENT_METHODS t
        WHERE t.payment_method_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_PAYMENT_METHODS (
    payment_method_id, payment_method_name, ta_insert_dt, source_system, source_entity, source_payment_method_id
)
SELECT
    n.payment_method_id,
    n.nm,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_PAYMENT_STATUSES IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(payment_status), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(payment_status_id), 0) AS m FROM LKP_PAYMENT_STATUSES),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS payment_status_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_PAYMENT_STATUSES t
        WHERE t.payment_status_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_PAYMENT_STATUSES (
    payment_status_id, payment_status_name, ta_insert_dt, source_system, source_entity, source_payment_status_id
)
SELECT
    n.payment_status_id,
    n.nm,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_PAYMENT_CURRENCIES IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(payment_currency), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(payment_currency_id), 0) AS m FROM LKP_PAYMENT_CURRENCIES),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS payment_currency_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_PAYMENT_CURRENCIES t
        WHERE t.payment_currency_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_PAYMENT_CURRENCIES (
    payment_currency_id, payment_currency_name, ta_insert_dt, source_system, source_entity, source_payment_currency_id
)
SELECT
    n.payment_currency_id,
    n.nm,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE LKP_PAYMENT_PROCESSORS IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(payment_processor), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(payment_processor_id), 0) AS m FROM LKP_PAYMENT_PROCESSORS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS payment_processor_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM LKP_PAYMENT_PROCESSORS t
        WHERE t.payment_processor_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO LKP_PAYMENT_PROCESSORS (
    payment_processor_id, payment_processor_name, ta_insert_dt, source_system, source_entity, source_payment_processor_id
)
SELECT
    n.payment_processor_id,
    n.nm,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_PRODUCT_CATEGORIES IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(product_category), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(category_id), 0) AS m FROM CE_PRODUCT_CATEGORIES),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS category_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_PRODUCT_CATEGORIES t
        WHERE t.category_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO CE_PRODUCT_CATEGORIES (
    category_id, category_name, ta_insert_dt, source_system, source_entity, source_category_id
)
SELECT
    n.category_id,
    n.nm,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_PRODUCT_BRANDS IN EXCLUSIVE MODE;

WITH v AS (
    SELECT DISTINCT COALESCE(NULLIF(TRIM(product_brand), ''), 'UNKNOWN') AS nm
    FROM sa_offline.src_offline_sales
),
mx AS (SELECT COALESCE(MAX(brand_id), 0) AS m FROM CE_PRODUCT_BRANDS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY v.nm) AS brand_id, v.nm
    FROM v
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_PRODUCT_BRANDS t
        WHERE t.brand_name=v.nm
          AND t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
    )
)
INSERT INTO CE_PRODUCT_BRANDS (
    brand_id, brand_name, ta_insert_dt, source_system, source_entity, source_brand_id
)
SELECT
    n.brand_id,
    n.nm,
    CURRENT_TIMESTAMP,
    'SA_OFFLINE',
    'SRC_OFFLINE_SALES',
    'SA_OFFLINE|SRC_OFFLINE_SALES|' || n.nm
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_PRODUCTS_SCD IN EXCLUSIVE MODE;

WITH src_products AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(product_id), ''), 'UNKNOWN') AS source_product_id,
        COALESCE(NULLIF(TRIM(product_name), ''), 'UNKNOWN') AS product_name,
        COALESCE(NULLIF(TRIM(product_category), ''), 'UNKNOWN') AS category_name,
        COALESCE(NULLIF(TRIM(product_brand), ''), 'UNKNOWN') AS brand_name,
        COALESCE(NULLIF(TRIM(product_description), ''), 'UNKNOWN') AS product_description,
        COALESCE(NULLIF(TRIM(product_country_of_origin), ''), 'UNKNOWN') AS country_name,
        COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(product_price), ''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::numeric(12,2) AS product_price,
        COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(product_margin_rate), ''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::numeric(5,2) AS product_margin_rate
    FROM sa_offline.src_offline_sales
),
existing AS (
    SELECT source_product_id
    FROM CE_PRODUCTS_SCD
    WHERE source_system='SA_OFFLINE' AND source_entity='SRC_OFFLINE_SALES'
    GROUP BY source_product_id
),
mx AS (SELECT COALESCE(MAX(product_id), 0) AS m FROM CE_PRODUCTS_SCD),
new_map AS (
    SELECT sp.source_product_id,
           (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY sp.source_product_id) AS product_id
    FROM src_products sp
    LEFT JOIN existing e ON e.source_product_id = sp.source_product_id
    WHERE e.source_product_id IS NULL
),
full_map AS (
    SELECT p.source_product_id, MIN(p.product_id) AS product_id
    FROM CE_PRODUCTS_SCD p
    WHERE p.source_system='SA_OFFLINE' AND p.source_entity='SRC_OFFLINE_SALES'
    GROUP BY p.source_product_id
    UNION ALL
    SELECT source_product_id, product_id FROM new_map
),
resolved AS (
    SELECT
        fm.product_id,
        TIMESTAMP '1900-01-01 00:00:00' AS ta_start_dt,
        sp.source_product_id,
        sp.product_name,
        c.category_id,
        b.brand_id,
        sp.product_description,
        sp.product_price,
        co.country_id AS product_country_of_origin_id,
        sp.product_margin_rate,
        TIMESTAMP '9999-12-31 00:00:00' AS ta_end_dt,
        TRUE AS is_active,
        CURRENT_TIMESTAMP AS ta_insert_dt,
        'SA_OFFLINE' AS source_system,
        'SRC_OFFLINE_SALES' AS source_entity
    FROM src_products sp
    JOIN full_map fm
      ON fm.source_product_id = sp.source_product_id
    JOIN CE_PRODUCT_CATEGORIES c
      ON c.category_name=sp.category_name
     AND c.source_system='SA_OFFLINE'
     AND c.source_entity='SRC_OFFLINE_SALES'
    JOIN CE_PRODUCT_BRANDS b
      ON b.brand_name=sp.brand_name
     AND b.source_system='SA_OFFLINE'
     AND b.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_COUNTRIES co
      ON co.country_name=sp.country_name
     AND co.source_system='SA_OFFLINE'
     AND co.source_entity='SRC_OFFLINE_SALES'
)
INSERT INTO CE_PRODUCTS_SCD (
    product_id, ta_start_dt, source_product_id, product_name, category_id, brand_id,
    product_description, product_price, product_country_of_origin_id, product_margin_rate,
    ta_end_dt, is_active, ta_insert_dt, source_system, source_entity
)
SELECT
    r.product_id, r.ta_start_dt, r.source_product_id, r.product_name, r.category_id, r.brand_id,
    r.product_description, r.product_price, r.product_country_of_origin_id, r.product_margin_rate,
    r.ta_end_dt, r.is_active, r.ta_insert_dt, r.source_system, r.source_entity
FROM resolved r
WHERE NOT EXISTS (
    SELECT 1 FROM CE_PRODUCTS_SCD t
    WHERE t.product_id=r.product_id AND t.ta_start_dt=r.ta_start_dt
);

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_STORES IN EXCLUSIVE MODE;

WITH src_stores AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(store_id), ''), 'UNKNOWN') AS source_store_id,
        COALESCE(NULLIF(TRIM(store_name), ''), 'UNKNOWN') AS store_name,
        COALESCE(NULLIF(TRIM(store_format), ''), 'UNKNOWN') AS store_format_name,
        COALESCE(NULLIF(TRIM(store_address_country), ''), 'UNKNOWN') AS country_name,
        COALESCE(NULLIF(TRIM(store_address_region), ''), 'UNKNOWN') AS region_name,
        COALESCE(NULLIF(TRIM(store_address_city), ''), 'UNKNOWN') AS city_name,
        COALESCE(NULLIF(TRIM(store_address_street), ''), 'UNKNOWN') AS street,
        COALESCE(NULLIF(TRIM(store_address_house_number), ''), 'UNKNOWN') AS house_number,
        COALESCE(NULLIF(TRIM(store_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
        COALESCE(NULLIF(TRIM(store_address_postal_code), ''), 'UNKNOWN') AS postal_code
    FROM sa_offline.src_offline_sales
),
to_insert AS (
    SELECT
        ss.source_store_id,
        ss.store_name,
        sf.store_format_id,
        a.address_id
    FROM src_stores ss
    JOIN LKP_STORE_FORMATS sf
      ON sf.store_format_name=ss.store_format_name
     AND sf.source_system='SA_OFFLINE'
     AND sf.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_ADDRESSES a
      ON a.source_address_id =
         ('SA_OFFLINE|SRC_OFFLINE_SALES|' ||
          ss.country_name || '|' || ss.region_name || '|' || ss.city_name || '|' ||
          ss.street || '|' || ss.house_number || '|' || ss.apartment_number || '|' || ss.postal_code)
     AND a.source_system='SA_OFFLINE'
     AND a.source_entity='SRC_OFFLINE_SALES'
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_STORES t
        WHERE t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
          AND t.source_store_id=ss.source_store_id
    )
),
mx AS (SELECT COALESCE(MAX(store_id), 0) AS m FROM CE_STORES),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY ti.source_store_id) AS store_id, ti.*
    FROM to_insert ti
)
INSERT INTO CE_STORES (
    store_id, store_name, store_format_id, address_id,
    ta_insert_dt, ta_update_dt, source_system, source_entity, source_store_id
)
SELECT
    n.store_id, n.store_name, n.store_format_id, n.address_id,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'SA_OFFLINE', 'SRC_OFFLINE_SALES', n.source_store_id
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_CASHIERS IN EXCLUSIVE MODE;

WITH src_cashiers AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(cashier_id), ''), 'UNKNOWN') AS source_cashier_id,
        COALESCE(NULLIF(TRIM(cashier_first_name), ''), 'UNKNOWN') AS first_name,
        COALESCE(NULLIF(TRIM(cashier_last_name), ''), 'UNKNOWN') AS last_name,
        COALESCE(NULLIF(TRIM(cashier_email), ''), 'UNKNOWN') AS email,
        COALESCE(NULLIF(TRIM(cashier_phone), ''), 'UNKNOWN') AS phone,
        COALESCE(NULLIF(TRIM(cashier_employment_date), ''), 'UNKNOWN') AS employment_raw,
        COALESCE(NULLIF(TRIM(cashier_role), ''), 'UNKNOWN') AS role_name,
        COALESCE(NULLIF(TRIM(cashier_shift_code), ''), 'UNKNOWN') AS shift_name,
        COALESCE(NULLIF(TRIM(cashier_address_country), ''), 'UNKNOWN') AS country_name,
        COALESCE(NULLIF(TRIM(cashier_address_region), ''), 'UNKNOWN') AS region_name,
        COALESCE(NULLIF(TRIM(cashier_address_city), ''), 'UNKNOWN') AS city_name,
        COALESCE(NULLIF(TRIM(cashier_address_street), ''), 'UNKNOWN') AS street,
        COALESCE(NULLIF(TRIM(cashier_address_house_number), ''), 'UNKNOWN') AS house_number,
        COALESCE(NULLIF(TRIM(cashier_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
        COALESCE(NULLIF(TRIM(cashier_address_postal_code), ''), 'UNKNOWN') AS postal_code
    FROM sa_offline.src_offline_sales
),
to_insert AS (
    SELECT
        sc.source_cashier_id,
        sc.first_name,
        sc.last_name,
        sc.email,
        sc.phone,
        CASE WHEN sc.employment_raw ~ '^\d{4}-\d{2}-\d{2}' THEN sc.employment_raw::timestamp ELSE TIMESTAMP '1900-01-01 00:00:00' END AS employment_dt,
        r.role_id,
        sh.shift_id,
        a.address_id
    FROM src_cashiers sc
    JOIN LKP_ROLES r
      ON r.role_name=sc.role_name
     AND r.source_system='SA_OFFLINE'
     AND r.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_SHIFTS sh
      ON sh.shift_name=sc.shift_name
     AND sh.source_system='SA_OFFLINE'
     AND sh.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_ADDRESSES a
      ON a.source_address_id =
         ('SA_OFFLINE|SRC_OFFLINE_SALES|' ||
          sc.country_name || '|' || sc.region_name || '|' || sc.city_name || '|' ||
          sc.street || '|' || sc.house_number || '|' || sc.apartment_number || '|' || sc.postal_code)
     AND a.source_system='SA_OFFLINE'
     AND a.source_entity='SRC_OFFLINE_SALES'
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_CASHIERS t
        WHERE t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
          AND t.source_cashier_id=sc.source_cashier_id
    )
),
mx AS (SELECT COALESCE(MAX(cashier_id), 0) AS m FROM CE_CASHIERS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY ti.source_cashier_id) AS cashier_id, ti.*
    FROM to_insert ti
)
INSERT INTO CE_CASHIERS (
    cashier_id, first_name, last_name, email, phone, employment_dt,
    role_id, shift_id, address_id,
    ta_insert_dt, ta_update_dt, source_system, source_entity, source_cashier_id
)
SELECT
    n.cashier_id, n.first_name, n.last_name, n.email, n.phone, n.employment_dt,
    n.role_id, n.shift_id, n.address_id,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'SA_OFFLINE', 'SRC_OFFLINE_SALES', n.source_cashier_id
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_CUSTOMERS IN EXCLUSIVE MODE;

WITH src_customers AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(customer_loyalty_card_number), ''), 'UNKNOWN') AS source_customer_id,
        COALESCE(NULLIF(TRIM(customer_first_name), ''), 'UNKNOWN') AS first_name,
        COALESCE(NULLIF(TRIM(customer_last_name), ''), 'UNKNOWN') AS last_name,
        COALESCE(NULLIF(TRIM(customer_email), ''), 'UNKNOWN') AS email,
        COALESCE(NULLIF(TRIM(customer_phone), ''), 'UNKNOWN') AS phone,
        COALESCE(NULLIF(TRIM(customer_registration_date), ''), 'UNKNOWN') AS registration_raw,
        COALESCE(NULLIF(TRIM(customer_preferred_communication_channel), ''), 'UNKNOWN') AS comm_channel_name,
        COALESCE(NULLIF(TRIM(customer_address_country), ''), 'UNKNOWN') AS country_name,
        COALESCE(NULLIF(TRIM(customer_address_region), ''), 'UNKNOWN') AS region_name,
        COALESCE(NULLIF(TRIM(customer_address_city), ''), 'UNKNOWN') AS city_name,
        COALESCE(NULLIF(TRIM(customer_address_street), ''), 'UNKNOWN') AS street,
        COALESCE(NULLIF(TRIM(customer_address_house_number), ''), 'UNKNOWN') AS house_number,
        COALESCE(NULLIF(TRIM(customer_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
        COALESCE(NULLIF(TRIM(customer_address_postal_code), ''), 'UNKNOWN') AS postal_code
    FROM sa_offline.src_offline_sales
),
to_insert AS (
    SELECT
        sc.source_customer_id,
        sc.first_name,
        sc.last_name,
        sc.email,
        sc.phone,
        CASE WHEN sc.registration_raw ~ '^\d{4}-\d{2}-\d{2}' THEN sc.registration_raw::timestamp ELSE TIMESTAMP '1900-01-01 00:00:00' END AS registration_dt,
        a.address_id,
        cc.communication_channel_id AS preferred_communication_channel_id,
        sc.source_customer_id AS loyalty_card_number
    FROM src_customers sc
    JOIN LKP_COMMUNICATION_CHANNELS cc
      ON cc.communication_channel_name=sc.comm_channel_name
     AND cc.source_system='SA_OFFLINE'
     AND cc.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_ADDRESSES a
      ON a.source_address_id =
         ('SA_OFFLINE|SRC_OFFLINE_SALES|' ||
          sc.country_name || '|' || sc.region_name || '|' || sc.city_name || '|' ||
          sc.street || '|' || sc.house_number || '|' || sc.apartment_number || '|' || sc.postal_code)
     AND a.source_system='SA_OFFLINE'
     AND a.source_entity='SRC_OFFLINE_SALES'
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_CUSTOMERS t
        WHERE t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
          AND t.source_customer_id=sc.source_customer_id
    )
),
mx AS (SELECT COALESCE(MAX(customer_id), 0) AS m FROM CE_CUSTOMERS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY ti.source_customer_id) AS customer_id, ti.*
    FROM to_insert ti
)
INSERT INTO CE_CUSTOMERS (
    customer_id, first_name, last_name, email, phone, registration_dt,
    address_id, preferred_communication_channel_id, loyalty_card_number,
    ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
)
SELECT
    n.customer_id, n.first_name, n.last_name, n.email, n.phone, n.registration_dt,
    n.address_id, n.preferred_communication_channel_id, n.loyalty_card_number,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'SA_OFFLINE', 'SRC_OFFLINE_SALES', n.source_customer_id
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_ORDERS IN EXCLUSIVE MODE;

WITH src_orders AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(order_id), ''), 'UNKNOWN') AS source_order_id,
        COALESCE(NULLIF(TRIM(customer_loyalty_card_number), ''), 'UNKNOWN') AS source_customer_id,
        COALESCE(NULLIF(TRIM(order_status), ''), 'UNKNOWN') AS order_status_name,
        COALESCE(NULLIF(TRIM(order_date), ''), 'UNKNOWN') AS order_date_raw
    FROM sa_offline.src_offline_sales
),
to_insert AS (
    SELECT
        so.source_order_id,
        c.customer_id,
        ch.channel_id,
        os.order_status_id,
        CASE WHEN so.order_date_raw ~ '^\d{4}-\d{2}-\d{2}' THEN so.order_date_raw::timestamp ELSE TIMESTAMP '1900-01-01 00:00:00' END AS order_dt
    FROM src_orders so
    JOIN CE_CUSTOMERS c
      ON c.source_system='SA_OFFLINE'
     AND c.source_entity='SRC_OFFLINE_SALES'
     AND c.source_customer_id=so.source_customer_id
    JOIN LKP_CHANNELS ch
      ON ch.channel_name='OFFLINE'
     AND ch.source_system='SA_OFFLINE'
     AND ch.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_ORDER_STATUSES os
      ON os.order_status_name=so.order_status_name
     AND os.source_system='SA_OFFLINE'
     AND os.source_entity='SRC_OFFLINE_SALES'
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_ORDERS t
        WHERE t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
          AND t.source_order_id=so.source_order_id
    )
),
mx AS (SELECT COALESCE(MAX(order_id), 0) AS m FROM CE_ORDERS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY ti.source_order_id) AS order_id, ti.*
    FROM to_insert ti
)
INSERT INTO CE_ORDERS (
    order_id, source_order_id, customer_id, channel_id, order_status_id,
    order_dt, ta_insert_dt, ta_update_dt, source_system, source_entity
)
SELECT
    n.order_id, n.source_order_id, n.customer_id, n.channel_id, n.order_status_id,
    n.order_dt, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'SA_OFFLINE', 'SRC_OFFLINE_SALES'
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_ORDERS_OFFLINE IN EXCLUSIVE MODE;

WITH x AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(order_id), ''), 'UNKNOWN') AS source_order_id,
        COALESCE(NULLIF(TRIM(store_id), ''), 'UNKNOWN') AS source_store_id,
        COALESCE(NULLIF(TRIM(cashier_id), ''), 'UNKNOWN') AS source_cashier_id
    FROM sa_offline.src_offline_sales
)
INSERT INTO CE_ORDERS_OFFLINE (order_id, store_id, cashier_id)
SELECT
    o.order_id,
    st.store_id,
    ca.cashier_id
FROM x
JOIN CE_ORDERS o
  ON o.source_system='SA_OFFLINE' AND o.source_entity='SRC_OFFLINE_SALES'
 AND o.source_order_id=x.source_order_id
JOIN CE_STORES st
  ON st.source_system='SA_OFFLINE' AND st.source_entity='SRC_OFFLINE_SALES'
 AND st.source_store_id=x.source_store_id
JOIN CE_CASHIERS ca
  ON ca.source_system='SA_OFFLINE' AND ca.source_entity='SRC_OFFLINE_SALES'
 AND ca.source_cashier_id=x.source_cashier_id
WHERE NOT EXISTS (
    SELECT 1 FROM CE_ORDERS_OFFLINE t WHERE t.order_id=o.order_id
);

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_PAYMENTS IN EXCLUSIVE MODE;

WITH src_payments AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(payment_id), ''), 'UNKNOWN') AS source_payment_id,
        COALESCE(NULLIF(TRIM(order_id), ''), 'UNKNOWN') AS source_order_id,
        COALESCE(NULLIF(TRIM(payment_method), ''), 'UNKNOWN') AS payment_method_name,
        COALESCE(NULLIF(TRIM(payment_status), ''), 'UNKNOWN') AS payment_status_name,
        COALESCE(NULLIF(TRIM(payment_currency), ''), 'UNKNOWN') AS payment_currency_name,
        COALESCE(NULLIF(TRIM(payment_processor), ''), 'UNKNOWN') AS payment_processor_name,
        COALESCE(NULLIF(TRIM(payment_date), ''), 'UNKNOWN') AS payment_date_raw
    FROM sa_offline.src_offline_sales
),
to_insert AS (
    SELECT
        sp.source_payment_id,
        pm.payment_method_id,
        ps.payment_status_id,
        pc.payment_currency_id,
        pp.payment_processor_id,
        o.order_id,
        CASE WHEN sp.payment_date_raw ~ '^\d{4}-\d{2}-\d{2}' THEN sp.payment_date_raw::timestamp ELSE TIMESTAMP '1900-01-01 00:00:00' END AS payment_dt
    FROM src_payments sp
    JOIN CE_ORDERS o
      ON o.source_system='SA_OFFLINE' AND o.source_entity='SRC_OFFLINE_SALES'
     AND o.source_order_id=sp.source_order_id
    JOIN LKP_PAYMENT_METHODS pm
      ON pm.payment_method_name=sp.payment_method_name
     AND pm.source_system='SA_OFFLINE' AND pm.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_PAYMENT_STATUSES ps
      ON ps.payment_status_name=sp.payment_status_name
     AND ps.source_system='SA_OFFLINE' AND ps.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_PAYMENT_CURRENCIES pc
      ON pc.payment_currency_name=sp.payment_currency_name
     AND pc.source_system='SA_OFFLINE' AND pc.source_entity='SRC_OFFLINE_SALES'
    JOIN LKP_PAYMENT_PROCESSORS pp
      ON pp.payment_processor_name=sp.payment_processor_name
     AND pp.source_system='SA_OFFLINE' AND pp.source_entity='SRC_OFFLINE_SALES'
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_PAYMENTS t
        WHERE t.source_system='SA_OFFLINE'
          AND t.source_entity='SRC_OFFLINE_SALES'
          AND t.source_payment_id=sp.source_payment_id
    )
),
mx AS (SELECT COALESCE(MAX(payment_id), 0) AS m FROM CE_PAYMENTS),
n AS (
    SELECT (SELECT m FROM mx) + ROW_NUMBER() OVER (ORDER BY ti.source_payment_id) AS payment_id, ti.*
    FROM to_insert ti
)
INSERT INTO CE_PAYMENTS (
    payment_id, source_payment_id, payment_method_id, payment_status_id,
    payment_currency_id, payment_processor_id, order_id, payment_dt,
    ta_insert_dt, ta_update_dt, source_system, source_entity
)
SELECT
    n.payment_id, n.source_payment_id, n.payment_method_id, n.payment_status_id,
    n.payment_currency_id, n.payment_processor_id, n.order_id, n.payment_dt,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'SA_OFFLINE', 'SRC_OFFLINE_SALES'
FROM n;

COMMIT;

-------------
BEGIN;
LOCK TABLE CE_ORDER_ITEMS IN EXCLUSIVE MODE;

WITH order_map AS (
    SELECT order_id, source_order_id
    FROM CE_ORDERS
    WHERE source_system='SA_OFFLINE' AND source_entity='SRC_OFFLINE_SALES'
),
product_map AS (
    SELECT source_product_id, MIN(product_id) AS product_id
    FROM CE_PRODUCTS_SCD
    WHERE source_system='SA_OFFLINE' AND source_entity='SRC_OFFLINE_SALES'
      AND ta_end_dt = TIMESTAMP '9999-12-31 00:00:00'
      AND is_active = TRUE
    GROUP BY source_product_id
),
src_items AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(order_id), ''), 'UNKNOWN') AS source_order_id,
        COALESCE(NULLIF(TRIM(product_id), ''), 'UNKNOWN') AS source_product_id,
        COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(order_item_quantity), ''), '0'), '[^0-9\-]', '', 'g'), ''), '0')::int AS quantity,
        COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(order_total_amount), ''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::numeric(12,2) AS order_item_amount,
        COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(order_item_discount_amount), ''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::numeric(12,2) AS discount_amount
    FROM sa_offline.src_offline_sales
),
to_insert AS (
    SELECT
        om.order_id,
        pm.product_id,
        si.quantity,
        si.order_item_amount,
        si.discount_amount,
        (si.source_order_id || '|' || si.source_product_id) AS source_order_item_id
    FROM src_items si
    JOIN order_map om ON om.source_order_id=si.source_order_id
    JOIN product_map pm ON pm.source_product_id=si.source_product_id
    WHERE NOT EXISTS (
        SELECT 1 FROM CE_ORDER_ITEMS t
        WHERE t.order_id=om.order_id AND t.product_id=pm.product_id
    )
)
INSERT INTO CE_ORDER_ITEMS (
    order_id, product_id, quantity, order_item_amount, discount_amount,
    ta_insert_dt, ta_update_dt, source_system, source_entity, source_order_item_id
)
SELECT
    ti.order_id, ti.product_id, ti.quantity, ti.order_item_amount, ti.discount_amount,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'SA_OFFLINE', 'SRC_OFFLINE_SALES', ti.source_order_item_id
FROM to_insert ti;

COMMIT;