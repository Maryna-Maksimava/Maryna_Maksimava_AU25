CREATE SCHEMA IF NOT EXISTS BL_CL;
  

DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bl_cl_role') THEN
        CREATE ROLE bl_cl_role;
    END IF;
END $$;
 
GRANT bl_cl_role TO CURRENT_USER;
 
GRANT USAGE  ON SCHEMA sa_online  TO bl_cl_role;
GRANT USAGE  ON SCHEMA sa_offline TO bl_cl_role;
GRANT SELECT ON ALL TABLES IN SCHEMA sa_online  TO bl_cl_role;
GRANT SELECT ON ALL TABLES IN SCHEMA sa_offline TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA sa_online  GRANT SELECT ON TABLES TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA sa_offline GRANT SELECT ON TABLES TO bl_cl_role;
 
GRANT USAGE                       ON SCHEMA BL_3NF TO bl_cl_role;
GRANT SELECT, INSERT, UPDATE      ON ALL TABLES IN SCHEMA BL_3NF TO bl_cl_role;
GRANT USAGE                       ON ALL SEQUENCES IN SCHEMA BL_3NF TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA BL_3NF
    GRANT SELECT, INSERT, UPDATE ON TABLES    TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA BL_3NF
    GRANT USAGE                  ON SEQUENCES TO bl_cl_role;
 
GRANT USAGE, CREATE               ON SCHEMA BL_CL TO bl_cl_role;
GRANT SELECT, INSERT, UPDATE      ON ALL TABLES IN SCHEMA BL_CL TO bl_cl_role;
GRANT USAGE                       ON ALL SEQUENCES IN SCHEMA BL_CL TO bl_cl_role;
    

CREATE TABLE IF NOT EXISTS BL_CL.LOAD_LOG (
    log_id          BIGSERIAL    PRIMARY KEY,
    log_dt          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    procedure_name  VARCHAR(255) NOT NULL,
    target_table    VARCHAR(255) NOT NULL,
    source_system   VARCHAR(255) NOT NULL,
    rows_affected   INT          NOT NULL DEFAULT 0,
    status          VARCHAR(50)  NOT NULL,
    message         TEXT
);


 

CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_country_id       START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_region_id        START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_city_id          START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_address_id       START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_comm_channel_id  START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_order_status_id  START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_pay_method_id    START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_pay_status_id    START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_pay_currency_id  START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_pay_processor_id START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_del_status_id    START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_del_type_id      START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_store_format_id  START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_wh_type_id       START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_courier_id       START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_role_id          START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_shift_id         START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_channel_id       START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_category_id      START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_brand_id         START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_product_id       START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_warehouse_id     START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_store_id         START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_customer_id      START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_cashier_id       START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_order_id         START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_payment_id  START 1;
CREATE SEQUENCE IF NOT EXISTS BL_3NF.seq_delivery_id START 1;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA BL_3NF TO bl_cl_role;
 

CREATE OR REPLACE PROCEDURE BL_CL.log_load(
    p_procedure_name VARCHAR,
    p_target_table   VARCHAR,
    p_source_system  VARCHAR,
    p_rows_affected  INT,
    p_status         VARCHAR,
    p_message        TEXT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO BL_CL.LOAD_LOG (
        log_dt, procedure_name, target_table, source_system,
        rows_affected, status, message
    )
    VALUES (
        CURRENT_TIMESTAMP,
        p_procedure_name,
        p_target_table,
        p_source_system,
        p_rows_affected,
        p_status,
        p_message
    );
END;
$$;



CREATE OR REPLACE FUNCTION BL_CL.fn_get_new_addresses(
    p_source_system VARCHAR,
    p_source_entity VARCHAR
)
RETURNS TABLE (
    street              VARCHAR,
    house_number        VARCHAR,
    apartment_number    VARCHAR,
    postal_code         VARCHAR,
    city_id             INT,
    source_address_id   VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_source_system = 'SA_ONLINE' AND p_source_entity = 'SRC_ONLINE_SALES' THEN
        RETURN QUERY
        WITH src AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN')::VARCHAR AS country_name,
                COALESCE(NULLIF(TRIM(s.region_name),  ''), 'UNKNOWN')::VARCHAR AS region_name,
                COALESCE(NULLIF(TRIM(s.city_name),    ''), 'UNKNOWN')::VARCHAR AS city_name,
                COALESCE(NULLIF(TRIM(s.street),       ''), 'UNKNOWN')::VARCHAR AS street,
                COALESCE(NULLIF(TRIM(s.house_number), ''), 'UNKNOWN')::VARCHAR AS house_number,
                COALESCE(NULLIF(TRIM(s.apt),          ''), 'UNKNOWN')::VARCHAR AS apartment_number,
                COALESCE(NULLIF(TRIM(s.postal),       ''), 'UNKNOWN')::VARCHAR AS postal_code
            FROM (
                SELECT customer_address_country AS country_name,
                       customer_address_region  AS region_name,
                       customer_address_city    AS city_name,
                       customer_address_street  AS street,
                       customer_address_house_number     AS house_number,
                       customer_address_apartment_number AS apt,
                       customer_address_postal_code      AS postal
                FROM sa_online.src_online_sales
                UNION ALL
                SELECT delivery_address_country, delivery_address_region, delivery_address_city,
                       delivery_address_street, delivery_address_house_number,
                       delivery_address_apartment_number, delivery_address_postal_code
                FROM sa_online.src_online_sales
                UNION ALL
                SELECT warehouse_address_country, warehouse_address_region, warehouse_address_city,
                       warehouse_address_street, warehouse_address_house_number,
                       warehouse_address_apartment_number, warehouse_address_postal_code
                FROM sa_online.src_online_sales
            ) s
        ),
        a AS (
            SELECT DISTINCT
                src.street,
                src.house_number,
                src.apartment_number,
                src.postal_code,
                ci.city_id,
                ('SA_ONLINE|SRC_ONLINE_SALES|'
                 || src.country_name || '|' || src.region_name || '|' || src.city_name || '|'
                 || src.street || '|' || src.house_number || '|' || src.apartment_number || '|'
                 || src.postal_code)::VARCHAR AS source_address_id
            FROM src
            JOIN BL_3NF.LKP_COUNTRIES c
              ON c.country_name  = src.country_name
             AND c.source_system = 'SA_ONLINE' AND c.source_entity = 'SRC_ONLINE_SALES'
            JOIN BL_3NF.LKP_REGIONS r
              ON r.country_id    = c.country_id
             AND r.region_name   = src.region_name
             AND r.source_system = 'SA_ONLINE' AND r.source_entity = 'SRC_ONLINE_SALES'
            JOIN BL_3NF.LKP_CITIES ci
              ON ci.region_id    = r.region_id
             AND ci.city_name    = src.city_name
             AND ci.source_system = 'SA_ONLINE' AND ci.source_entity = 'SRC_ONLINE_SALES'
        )
        SELECT a.street::VARCHAR,
               a.house_number::VARCHAR,
               a.apartment_number::VARCHAR,
               a.postal_code::VARCHAR,
               a.city_id,
               a.source_address_id::VARCHAR
        FROM a
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_ADDRESSES t
            WHERE t.source_address_id = a.source_address_id
              AND t.source_system     = 'SA_ONLINE'
              AND t.source_entity     = 'SRC_ONLINE_SALES'
        );

    ELSIF p_source_system = 'SA_OFFLINE' AND p_source_entity = 'SRC_OFFLINE_SALES' THEN
        RETURN QUERY
        WITH src AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN')::VARCHAR AS country_name,
                COALESCE(NULLIF(TRIM(s.region_name),  ''), 'UNKNOWN')::VARCHAR AS region_name,
                COALESCE(NULLIF(TRIM(s.city_name),    ''), 'UNKNOWN')::VARCHAR AS city_name,
                COALESCE(NULLIF(TRIM(s.street),       ''), 'UNKNOWN')::VARCHAR AS street,
                COALESCE(NULLIF(TRIM(s.house_number), ''), 'UNKNOWN')::VARCHAR AS house_number,
                COALESCE(NULLIF(TRIM(s.apt),          ''), 'UNKNOWN')::VARCHAR AS apartment_number,
                COALESCE(NULLIF(TRIM(s.postal),       ''), 'UNKNOWN')::VARCHAR AS postal_code
            FROM (
                SELECT customer_address_country AS country_name,
                       customer_address_region  AS region_name,
                       customer_address_city    AS city_name,
                       customer_address_street  AS street,
                       customer_address_house_number     AS house_number,
                       customer_address_apartment_number AS apt,
                       customer_address_postal_code      AS postal
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
                ('SA_OFFLINE|SRC_OFFLINE_SALES|'
                 || src.country_name || '|' || src.region_name || '|' || src.city_name || '|'
                 || src.street || '|' || src.house_number || '|' || src.apartment_number || '|'
                 || src.postal_code)::VARCHAR AS source_address_id
            FROM src
            JOIN BL_3NF.LKP_COUNTRIES c
              ON c.country_name  = src.country_name
             AND c.source_system = 'SA_OFFLINE' AND c.source_entity = 'SRC_OFFLINE_SALES'
            JOIN BL_3NF.LKP_REGIONS r
              ON r.country_id    = c.country_id
             AND r.region_name   = src.region_name
             AND r.source_system = 'SA_OFFLINE' AND r.source_entity = 'SRC_OFFLINE_SALES'
            JOIN BL_3NF.LKP_CITIES ci
              ON ci.region_id    = r.region_id
             AND ci.city_name    = src.city_name
             AND ci.source_system = 'SA_OFFLINE' AND ci.source_entity = 'SRC_OFFLINE_SALES'
        )
        SELECT a.street::VARCHAR,
               a.house_number::VARCHAR,
               a.apartment_number::VARCHAR,
               a.postal_code::VARCHAR,
               a.city_id,
               a.source_address_id::VARCHAR
        FROM a
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_ADDRESSES t
            WHERE t.source_address_id = a.source_address_id
              AND t.source_system     = 'SA_OFFLINE'
              AND t.source_entity     = 'SRC_OFFLINE_SALES'
        );
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_countries_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_countries_online';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_COUNTRIES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_COUNTRIES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN') AS country_name
        FROM (
            SELECT customer_address_country  AS nm FROM sa_online.src_online_sales
            UNION ALL SELECT delivery_address_country        FROM sa_online.src_online_sales
            UNION ALL SELECT warehouse_address_country       FROM sa_online.src_online_sales
            UNION ALL SELECT product_country_of_origin       FROM sa_online.src_online_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_COUNTRIES t
            WHERE t.country_name  = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys
              AND t.source_entity = v_src_ent
        )
        ORDER BY country_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_COUNTRIES (
            country_id, country_code, country_name, ta_insert_dt,
            source_system, source_entity, src_country_id
        ) VALUES (
            nextval('BL_3NF.seq_country_id'),
            CASE WHEN LENGTH(r.country_name) >= 3 THEN UPPER(LEFT(r.country_name, 3))
                 ELSE UPPER(r.country_name) END,
            r.country_name, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.country_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new countries from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_countries_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_countries_offline';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_COUNTRIES';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_COUNTRIES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN') AS country_name
        FROM (
            SELECT customer_address_country AS nm FROM sa_offline.src_offline_sales
            UNION ALL SELECT store_address_country         FROM sa_offline.src_offline_sales
            UNION ALL SELECT cashier_address_country       FROM sa_offline.src_offline_sales
            UNION ALL SELECT product_country_of_origin     FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_COUNTRIES t
            WHERE t.country_name  = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys
              AND t.source_entity = v_src_ent
        )
        ORDER BY country_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_COUNTRIES (
            country_id, country_code, country_name, ta_insert_dt,
            source_system, source_entity, src_country_id
        ) VALUES (
            nextval('BL_3NF.seq_country_id'),
            CASE WHEN LENGTH(r.country_name) >= 3 THEN UPPER(LEFT(r.country_name, 3))
                 ELSE UPPER(r.country_name) END,
            r.country_name, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.country_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new countries from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_regions_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_regions_online';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_REGIONS';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_REGIONS IN EXCLUSIVE MODE;

    FOR r IN (
        WITH src AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(s.region_name),  ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN') AS country_name
            FROM (
                SELECT customer_address_region  AS region_name, customer_address_country  AS country_name FROM sa_online.src_online_sales
                UNION ALL SELECT delivery_address_region,  delivery_address_country  FROM sa_online.src_online_sales
                UNION ALL SELECT warehouse_address_region, warehouse_address_country FROM sa_online.src_online_sales
            ) s
        )
        SELECT src.region_name, c.country_id,
               v_src_sys || '|' || v_src_ent || '|' || src.country_name || '|' || src.region_name AS source_region_id
        FROM src
        JOIN BL_3NF.LKP_COUNTRIES c
          ON c.country_name  = src.country_name
         AND c.source_system = v_src_sys AND c.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_REGIONS t
            WHERE t.region_name   = src.region_name
              AND t.country_id    = c.country_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY c.country_id, src.region_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_REGIONS (
            region_id, region_name, country_id, ta_insert_dt,
            source_system, source_entity, source_region_id
        ) VALUES (
            nextval('BL_3NF.seq_country_id'), r.region_name, r.country_id, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent, r.source_region_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new regions from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_regions_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_regions_offline';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_REGIONS';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_REGIONS IN EXCLUSIVE MODE;

    FOR r IN (
        WITH src AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(s.region_name),  ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN') AS country_name
            FROM (
                SELECT customer_address_region  AS region_name, customer_address_country  AS country_name FROM sa_offline.src_offline_sales
                UNION ALL SELECT store_address_region,   store_address_country   FROM sa_offline.src_offline_sales
                UNION ALL SELECT cashier_address_region, cashier_address_country FROM sa_offline.src_offline_sales
            ) s
        )
        SELECT src.region_name, c.country_id,
               v_src_sys || '|' || v_src_ent || '|' || src.country_name || '|' || src.region_name AS source_region_id
        FROM src
        JOIN BL_3NF.LKP_COUNTRIES c
          ON c.country_name  = src.country_name
         AND c.source_system = v_src_sys AND c.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_REGIONS t
            WHERE t.region_name   = src.region_name
              AND t.country_id    = c.country_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY c.country_id, src.region_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_REGIONS (
            region_id, region_name, country_id, ta_insert_dt,
            source_system, source_entity, source_region_id
        ) VALUES (
            nextval('BL_3NF.seq_country_id'), r.region_name, r.country_id, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent, r.source_region_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new regions from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_cities_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_cities_online';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_CITIES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_CITIES IN EXCLUSIVE MODE;

    FOR r IN (
        WITH src AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(s.city_name),    ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(s.region_name),  ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN') AS country_name
            FROM (
                SELECT customer_address_city   AS city_name, customer_address_region  AS region_name, customer_address_country  AS country_name FROM sa_online.src_online_sales
                UNION ALL SELECT delivery_address_city,  delivery_address_region,  delivery_address_country  FROM sa_online.src_online_sales
                UNION ALL SELECT warehouse_address_city, warehouse_address_region, warehouse_address_country FROM sa_online.src_online_sales
            ) s
        )
        SELECT src.city_name, reg.region_id,
               v_src_sys || '|' || v_src_ent || '|' || src.country_name || '|' || src.region_name || '|' || src.city_name AS source_city_id
        FROM src
        JOIN BL_3NF.LKP_COUNTRIES c
          ON c.country_name  = src.country_name AND c.source_system = v_src_sys AND c.source_entity = v_src_ent
        JOIN BL_3NF.LKP_REGIONS reg
          ON reg.country_id  = c.country_id AND reg.region_name = src.region_name
         AND reg.source_system = v_src_sys AND reg.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_CITIES t
            WHERE t.city_name    = src.city_name
              AND t.region_id    = reg.region_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY reg.region_id, src.city_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_CITIES (
            city_id, city_name, region_id, ta_insert_dt,
            source_system, source_entity, source_city_id
        ) VALUES (
            nextval('BL_3NF.seq_region_id'), r.city_name, r.region_id, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent, r.source_city_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new cities from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_cities_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_cities_offline';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_CITIES';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_CITIES IN EXCLUSIVE MODE;

    FOR r IN (
        WITH src AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(s.city_name),    ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(s.region_name),  ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(s.country_name), ''), 'UNKNOWN') AS country_name
            FROM (
                SELECT customer_address_city   AS city_name, customer_address_region  AS region_name, customer_address_country  AS country_name FROM sa_offline.src_offline_sales
                UNION ALL SELECT store_address_city,   store_address_region,   store_address_country   FROM sa_offline.src_offline_sales
                UNION ALL SELECT cashier_address_city, cashier_address_region, cashier_address_country FROM sa_offline.src_offline_sales
            ) s
        )
        SELECT src.city_name, reg.region_id,
               v_src_sys || '|' || v_src_ent || '|' || src.country_name || '|' || src.region_name || '|' || src.city_name AS source_city_id
        FROM src
        JOIN BL_3NF.LKP_COUNTRIES c
          ON c.country_name  = src.country_name AND c.source_system = v_src_sys AND c.source_entity = v_src_ent
        JOIN BL_3NF.LKP_REGIONS reg
          ON reg.country_id  = c.country_id AND reg.region_name = src.region_name
         AND reg.source_system = v_src_sys AND reg.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_CITIES t
            WHERE t.city_name    = src.city_name
              AND t.region_id    = reg.region_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY reg.region_id, src.city_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_CITIES (
            city_id, city_name, region_id, ta_insert_dt,
            source_system, source_entity, source_city_id
        ) VALUES (
            nextval('BL_3NF.seq_region_id'), r.city_name, r.region_id, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent, r.source_city_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new cities from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_addresses_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_addresses_online';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_ADDRESSES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_ADDRESSES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT * FROM BL_CL.fn_get_new_addresses(v_src_sys, v_src_ent)
        ORDER BY city_id, street, house_number, apartment_number, postal_code
    ) LOOP
        INSERT INTO BL_3NF.LKP_ADDRESSES (
            address_id, street, house_number, apartment_number, postal_code,
            city_id, ta_insert_dt, source_entity, source_system, source_address_id
        ) VALUES (
            nextval('BL_3NF.seq_city_id'), r.street, r.house_number, r.apartment_number, r.postal_code,
            r.city_id, CURRENT_TIMESTAMP, v_src_ent, v_src_sys, r.source_address_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new addresses from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_addresses_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_addresses_offline';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_ADDRESSES';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_ADDRESSES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT * FROM BL_CL.fn_get_new_addresses(v_src_sys, v_src_ent)
        ORDER BY city_id, street, house_number, apartment_number, postal_code
    ) LOOP
        INSERT INTO BL_3NF.LKP_ADDRESSES (
            address_id, street, house_number, apartment_number, postal_code,
            city_id, ta_insert_dt, source_entity, source_system, source_address_id
        ) VALUES (
            nextval('BL_3NF.seq_city_id'), r.street, r.house_number, r.apartment_number, r.postal_code,
            r.city_id, CURRENT_TIMESTAMP, v_src_ent, v_src_sys, r.source_address_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new addresses from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_communication_channels()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_lkp_communication_channels';
    v_table  CONSTANT VARCHAR := 'BL_3NF.LKP_COMMUNICATION_CHANNELS';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_COMMUNICATION_CHANNELS IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS channel_name,
            src_sys, src_ent
        FROM (
            SELECT customer_preferred_communication_channel AS nm,
                   'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent
            FROM sa_online.src_online_sales
            UNION ALL
            SELECT customer_preferred_communication_channel,
                   'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent
            FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_COMMUNICATION_CHANNELS t
            WHERE t.communication_channel_name = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, channel_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_COMMUNICATION_CHANNELS (
            communication_channel_id, communication_channel_name, ta_insert_dt,
            source_system, source_entity, source_communication_channel_id
        ) VALUES (
            nextval('BL_3NF.seq_comm_channel_id'), r.channel_name, CURRENT_TIMESTAMP, r.src_sys, r.src_ent,
            r.src_sys || '|' || r.src_ent || '|' || r.channel_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new communication channels');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_order_statuses()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_lkp_order_statuses';
    v_table  CONSTANT VARCHAR := 'BL_3NF.LKP_ORDER_STATUSES';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_ORDER_STATUSES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS status_name,
            src_sys, src_ent
        FROM (
            SELECT order_status AS nm, 'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent FROM sa_online.src_online_sales
            UNION ALL
            SELECT order_status,       'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_ORDER_STATUSES t
            WHERE t.order_status_name = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, status_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_ORDER_STATUSES (
            order_status_id, order_status_name, ta_insert_dt, ta_update_dt,
            source_system, source_entity, source_status_id
        ) VALUES (
            nextval('BL_3NF.seq_order_status_id'), r.status_name, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
            r.src_sys, r.src_ent, r.src_sys || '|' || r.src_ent || '|' || r.status_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new order statuses');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_payment_methods()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_lkp_payment_methods';
    v_table  CONSTANT VARCHAR := 'BL_3NF.LKP_PAYMENT_METHODS';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_PAYMENT_METHODS IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS method_name, src_sys, src_ent
        FROM (
            SELECT payment_method AS nm, 'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent FROM sa_online.src_online_sales
            UNION ALL
            SELECT payment_method,       'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_PAYMENT_METHODS t
            WHERE t.payment_method_name = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, method_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_PAYMENT_METHODS (
            payment_method_id, payment_method_name, ta_insert_dt,
            source_system, source_entity, source_payment_method_id
        ) VALUES (
            nextval('BL_3NF.seq_pay_method_id'), r.method_name, CURRENT_TIMESTAMP,
            r.src_sys, r.src_ent, r.src_sys || '|' || r.src_ent || '|' || r.method_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new payment methods');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_payment_statuses()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_lkp_payment_statuses';
    v_table  CONSTANT VARCHAR := 'BL_3NF.LKP_PAYMENT_STATUSES';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_PAYMENT_STATUSES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS status_name, src_sys, src_ent
        FROM (
            SELECT payment_status AS nm, 'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent FROM sa_online.src_online_sales
            UNION ALL
            SELECT payment_status,       'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_PAYMENT_STATUSES t
            WHERE t.payment_status_name = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, status_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_PAYMENT_STATUSES (
            payment_status_id, payment_status_name, ta_insert_dt,
            source_system, source_entity, source_payment_status_id
        ) VALUES (
            nextval('BL_3NF.seq_pay_status_id'), r.status_name, CURRENT_TIMESTAMP,
            r.src_sys, r.src_ent, r.src_sys || '|' || r.src_ent || '|' || r.status_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new payment statuses');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_payment_currencies()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_lkp_payment_currencies';
    v_table  CONSTANT VARCHAR := 'BL_3NF.LKP_PAYMENT_CURRENCIES';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_PAYMENT_CURRENCIES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS currency_name, src_sys, src_ent
        FROM (
            SELECT payment_currency AS nm, 'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent FROM sa_online.src_online_sales
            UNION ALL
            SELECT payment_currency,       'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_PAYMENT_CURRENCIES t
            WHERE t.payment_currency_name = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, currency_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_PAYMENT_CURRENCIES (
            payment_currency_id, payment_currency_name, ta_insert_dt,
            source_system, source_entity, source_payment_currency_id
        ) VALUES (
            nextval('BL_3NF.seq_pay_currency_id'), r.currency_name, CURRENT_TIMESTAMP,
            r.src_sys, r.src_ent, r.src_sys || '|' || r.src_ent || '|' || r.currency_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new payment currencies');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_payment_processors()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_lkp_payment_processors';
    v_table  CONSTANT VARCHAR := 'BL_3NF.LKP_PAYMENT_PROCESSORS';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_PAYMENT_PROCESSORS IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS processor_name, src_sys, src_ent
        FROM (
            SELECT payment_processor AS nm, 'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent FROM sa_online.src_online_sales
            UNION ALL
            SELECT payment_processor,       'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_PAYMENT_PROCESSORS t
            WHERE t.payment_processor_name = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, processor_name
    ) LOOP
        INSERT INTO BL_3NF.LKP_PAYMENT_PROCESSORS (
            payment_processor_id, payment_processor_name, ta_insert_dt,
            source_system, source_entity, source_payment_processor_id
        ) VALUES (
            nextval('BL_3NF.seq_pay_processor_id'), r.processor_name, CURRENT_TIMESTAMP,
            r.src_sys, r.src_ent, r.src_sys || '|' || r.src_ent || '|' || r.processor_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new payment processors');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_delivery_statuses()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_delivery_statuses';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_DELIVERY_STATUSES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_DELIVERY_STATUSES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(delivery_status), ''), 'UNKNOWN') AS nm
        FROM sa_online.src_online_sales
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_DELIVERY_STATUSES t
            WHERE t.delivery_status_name = COALESCE(NULLIF(TRIM(delivery_status), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY nm
    ) LOOP
        INSERT INTO BL_3NF.LKP_DELIVERY_STATUSES (
            delivery_status_id, delivery_status_name, ta_insert_dt,
            source_system, source_entity, source_delivery_status_id
        ) VALUES (
            nextval('BL_3NF.seq_del_status_id'), r.nm, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.nm
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new delivery statuses');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_delivery_types()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_delivery_types';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_DELIVERY_TYPES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_DELIVERY_TYPES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(delivery_type), ''), 'UNKNOWN') AS nm
        FROM sa_online.src_online_sales
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_DELIVERY_TYPES t
            WHERE t.delivery_type_name = COALESCE(NULLIF(TRIM(delivery_type), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY nm
    ) LOOP
        INSERT INTO BL_3NF.LKP_DELIVERY_TYPES (
            delivery_type_id, delivery_type_name, ta_insert_dt,
            source_system, source_entity, source_delivery_type_id
        ) VALUES (
            nextval('BL_3NF.seq_del_type_id'), r.nm, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.nm
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new delivery types');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_store_formats()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_store_formats';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_STORE_FORMATS';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_STORE_FORMATS IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(store_format), ''), 'UNKNOWN') AS nm
        FROM sa_offline.src_offline_sales
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_STORE_FORMATS t
            WHERE t.store_format_name = COALESCE(NULLIF(TRIM(store_format), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY nm
    ) LOOP
        INSERT INTO BL_3NF.LKP_STORE_FORMATS (
            store_format_id, store_format_name, ta_insert_dt,
            source_system, source_entity, source_store_format_id
        ) VALUES (
            nextval('BL_3NF.seq_store_format_id'), r.nm, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.nm
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new store formats');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_warehouse_types()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_warehouse_types';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_WAREHOUSE_TYPES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_WAREHOUSE_TYPES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(warehouse_type), ''), 'UNKNOWN') AS nm
        FROM sa_online.src_online_sales
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_WAREHOUSE_TYPES t
            WHERE t.warehouse_type_name = COALESCE(NULLIF(TRIM(warehouse_type), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY nm
    ) LOOP
        INSERT INTO BL_3NF.LKP_WAREHOUSE_TYPES (
            warehouse_type_id, warehouse_type_name, ta_insert_dt,
            source_system, source_entity, source_warehouse_type_id
        ) VALUES (
            nextval('BL_3NF.seq_wh_type_id'), r.nm, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.nm
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new warehouse types');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_courier_companies()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_courier_companies';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_COURIER_COMPANIES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_COURIER_COMPANIES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(courier_company), ''), 'UNKNOWN') AS nm
        FROM sa_online.src_online_sales
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_COURIER_COMPANIES t
            WHERE t.courier_company_name = COALESCE(NULLIF(TRIM(courier_company), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY nm
    ) LOOP
        INSERT INTO BL_3NF.LKP_COURIER_COMPANIES (
            courier_company_id, courier_company_name, ta_insert_dt,
            source_system, source_entity, source_courier_company_id
        ) VALUES (
            nextval('BL_3NF.seq_courier_id'), r.nm, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.nm
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new courier companies');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_roles()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_roles';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_ROLES';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_ROLES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(cashier_role), ''), 'UNKNOWN') AS nm
        FROM sa_offline.src_offline_sales
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_ROLES t
            WHERE t.role_name     = COALESCE(NULLIF(TRIM(cashier_role), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY nm
    ) LOOP
        INSERT INTO BL_3NF.LKP_ROLES (
            role_id, role_name, ta_insert_dt,
            source_system, source_entity, source_role_id
        ) VALUES (
            nextval('BL_3NF.seq_role_id'), r.nm, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.nm
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new roles');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_lkp_shifts()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_lkp_shifts';
    v_table   CONSTANT VARCHAR := 'BL_3NF.LKP_SHIFTS';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.LKP_SHIFTS IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT COALESCE(NULLIF(TRIM(cashier_shift_code), ''), 'UNKNOWN') AS nm
        FROM sa_offline.src_offline_sales
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.LKP_SHIFTS t
            WHERE t.shift_name    = COALESCE(NULLIF(TRIM(cashier_shift_code), ''), 'UNKNOWN')
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY nm
    ) LOOP
        INSERT INTO BL_3NF.LKP_SHIFTS (
            shift_id, shift_name, ta_insert_dt,
            source_system, source_entity, source_shift_id
        ) VALUES (
            nextval('BL_3NF.seq_shift_id'), r.nm, CURRENT_TIMESTAMP, v_src_sys, v_src_ent,
            v_src_sys || '|' || v_src_ent || '|' || r.nm
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new shifts');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_product_categories()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_ce_product_categories';
    v_table  CONSTANT VARCHAR := 'BL_3NF.CE_PRODUCT_CATEGORIES';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_PRODUCT_CATEGORIES IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS category_name, src_sys, src_ent
        FROM (
            SELECT product_category AS nm, 'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent FROM sa_online.src_online_sales
            UNION ALL
            SELECT product_category,       'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PRODUCT_CATEGORIES t
            WHERE t.category_name = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, category_name
    ) LOOP
        INSERT INTO BL_3NF.CE_PRODUCT_CATEGORIES (
            category_id, category_name, ta_insert_dt,
            source_system, source_entity, source_category_id
        ) VALUES (
            nextval('BL_3NF.seq_category_id'), r.category_name, CURRENT_TIMESTAMP,
            r.src_sys, r.src_ent, r.src_sys || '|' || r.src_ent || '|' || r.category_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new product categories');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_product_brands()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_ce_product_brands';
    v_table  CONSTANT VARCHAR := 'BL_3NF.CE_PRODUCT_BRANDS';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_PRODUCT_BRANDS IN EXCLUSIVE MODE;

    FOR r IN (
        SELECT DISTINCT
            COALESCE(NULLIF(TRIM(nm), ''), 'UNKNOWN') AS brand_name, src_sys, src_ent
        FROM (
            SELECT product_brand AS nm, 'SA_ONLINE'  AS src_sys, 'SRC_ONLINE_SALES'  AS src_ent FROM sa_online.src_online_sales
            UNION ALL
            SELECT product_brand,       'SA_OFFLINE' AS src_sys, 'SRC_OFFLINE_SALES' AS src_ent FROM sa_offline.src_offline_sales
        ) x
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PRODUCT_BRANDS t
            WHERE t.brand_name    = COALESCE(NULLIF(TRIM(x.nm), ''), 'UNKNOWN')
              AND t.source_system = x.src_sys AND t.source_entity = x.src_ent
        )
        ORDER BY src_sys, brand_name
    ) LOOP
        INSERT INTO BL_3NF.CE_PRODUCT_BRANDS (
            brand_id, brand_name, ta_insert_dt,
            source_system, source_entity, source_brand_id
        ) VALUES (
            nextval('BL_3NF.seq_brand_id'), r.brand_name, CURRENT_TIMESTAMP,
            r.src_sys, r.src_ent, r.src_sys || '|' || r.src_ent || '|' || r.brand_name
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new product brands');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

 
CREATE OR REPLACE PROCEDURE BL_CL.load_ce_products_scd()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows   INT := 0;
    v_proc   CONSTANT VARCHAR := 'BL_CL.load_ce_products_scd';
    v_table  CONSTANT VARCHAR := 'BL_3NF.CE_PRODUCTS_SCD';
    r        RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_PRODUCTS_SCD IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sp AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(product_id),          ''), 'UNKNOWN') AS source_product_id,
                COALESCE(NULLIF(TRIM(product_name),        ''), 'UNKNOWN') AS product_name,
                COALESCE(NULLIF(TRIM(product_category),    ''), 'UNKNOWN') AS category_name,
                COALESCE(NULLIF(TRIM(product_brand),       ''), 'UNKNOWN') AS brand_name,
                COALESCE(NULLIF(TRIM(product_description), ''), 'UNKNOWN') AS product_description,
                COALESCE(NULLIF(TRIM(product_country_of_origin), ''), 'UNKNOWN') AS country_name,
                COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(product_price),''),'0'),'[^0-9\.\-]','','g'),''),'0')::NUMERIC(12,2) AS product_price,
                COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(product_margin_rate),''),'0'),'[^0-9\.\-]','','g'),''),'0')::NUMERIC(5,2) AS product_margin_rate,
                'SA_ONLINE'::VARCHAR  AS src_sys,
                'SRC_ONLINE_SALES'::VARCHAR AS src_ent
            FROM sa_online.src_online_sales
            UNION ALL
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(product_id),          ''), 'UNKNOWN'),
                COALESCE(NULLIF(TRIM(product_name),        ''), 'UNKNOWN'),
                COALESCE(NULLIF(TRIM(product_category),    ''), 'UNKNOWN'),
                COALESCE(NULLIF(TRIM(product_brand),       ''), 'UNKNOWN'),
                COALESCE(NULLIF(TRIM(product_description), ''), 'UNKNOWN'),
                COALESCE(NULLIF(TRIM(product_country_of_origin), ''), 'UNKNOWN'),
                COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(product_price),''),'0'),'[^0-9\.\-]','','g'),''),'0')::NUMERIC(12,2),
                COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(product_margin_rate),''),'0'),'[^0-9\.\-]','','g'),''),'0')::NUMERIC(5,2),
                'SA_OFFLINE'::VARCHAR,
                'SRC_OFFLINE_SALES'::VARCHAR
            FROM sa_offline.src_offline_sales
        )
        SELECT sp.source_product_id, sp.product_name, sp.product_description,
               sp.product_price, sp.product_margin_rate, sp.src_sys, sp.src_ent,
               c.category_id, b.brand_id, co.country_id AS product_country_of_origin_id
        FROM sp
        JOIN BL_3NF.CE_PRODUCT_CATEGORIES c
          ON c.category_name = sp.category_name AND c.source_system = sp.src_sys AND c.source_entity = sp.src_ent
        JOIN BL_3NF.CE_PRODUCT_BRANDS b
          ON b.brand_name    = sp.brand_name    AND b.source_system = sp.src_sys AND b.source_entity = sp.src_ent
        JOIN BL_3NF.LKP_COUNTRIES co
          ON co.country_name = sp.country_name  AND co.source_system = sp.src_sys AND co.source_entity = sp.src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PRODUCTS_SCD t
            WHERE t.source_product_id = sp.source_product_id
              AND t.source_system     = sp.src_sys
              AND t.source_entity     = sp.src_ent
              -- ↓ guards against re-running the initial load on the same sentinel date
              AND t.ta_start_dt       = TIMESTAMP '1900-01-01 00:00:00'
        )
        ORDER BY sp.src_sys, sp.source_product_id
    ) LOOP
        INSERT INTO BL_3NF.CE_PRODUCTS_SCD (
            product_id, ta_start_dt, source_product_id, product_name,
            category_id, brand_id, product_description, product_price,
            product_country_of_origin_id, product_margin_rate,
            ta_end_dt, is_active, ta_insert_dt, source_system, source_entity
        ) VALUES (
            nextval('BL_3NF.seq_product_id'),
            TIMESTAMP '1900-01-01 00:00:00',  
            r.source_product_id, r.product_name,
            r.category_id, r.brand_id, r.product_description, r.product_price,
            r.product_country_of_origin_id, r.product_margin_rate,
            TIMESTAMP '9999-12-31 00:00:00', TRUE, CURRENT_TIMESTAMP, r.src_sys, r.src_ent
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, 'ALL', v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new products from SA_ONLINE + SA_OFFLINE');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, 'ALL', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE BL_CL.load_ce_warehouses()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_warehouses';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_WAREHOUSES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_WAREHOUSES IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sw AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(warehouse_id),   ''), 'UNKNOWN') AS source_warehouse_id,
                COALESCE(NULLIF(TRIM(warehouse_type), ''), 'UNKNOWN') AS warehouse_type_name,
                COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(warehouse_capacity_units),''),'0'),'[^0-9]','','g'),''),'0')::INT AS capacity_units,
                COALESCE(NULLIF(regexp_replace(COALESCE(NULLIF(TRIM(warehouse_num_employees), ''), '0'),'[^0-9]','','g'),''),'0')::INT AS num_employees,
                COALESCE(NULLIF(TRIM(warehouse_address_country),          ''), 'UNKNOWN') AS country_name,
                COALESCE(NULLIF(TRIM(warehouse_address_region),           ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(warehouse_address_city),             ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(warehouse_address_street),           ''), 'UNKNOWN') AS street,
                COALESCE(NULLIF(TRIM(warehouse_address_house_number),     ''), 'UNKNOWN') AS house_number,
                COALESCE(NULLIF(TRIM(warehouse_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
                COALESCE(NULLIF(TRIM(warehouse_address_postal_code),      ''), 'UNKNOWN') AS postal_code
            FROM sa_online.src_online_sales
        )
        SELECT sw.source_warehouse_id, sw.capacity_units, sw.num_employees,
               wt.warehouse_type_id, a.address_id
        FROM sw
        JOIN BL_3NF.LKP_WAREHOUSE_TYPES wt
          ON wt.warehouse_type_name = sw.warehouse_type_name
         AND wt.source_system = v_src_sys AND wt.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ADDRESSES a
          ON a.source_address_id = v_src_sys || '|' || v_src_ent || '|' ||
             sw.country_name || '|' || sw.region_name || '|' || sw.city_name || '|' ||
             sw.street || '|' || sw.house_number || '|' || sw.apartment_number || '|' || sw.postal_code
         AND a.source_system = v_src_sys AND a.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_WAREHOUSES t
            WHERE t.source_warehouse_id = sw.source_warehouse_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY sw.source_warehouse_id
    ) LOOP
        INSERT INTO BL_3NF.CE_WAREHOUSES (
            warehouse_id, address_id, warehouse_type_id, capacity_units, num_employees,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_warehouse_id
        ) VALUES (
            nextval('BL_3NF.seq_address_id'), r.address_id, r.warehouse_type_id, r.capacity_units, r.num_employees,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_src_sys, v_src_ent, r.source_warehouse_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new warehouses');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_stores()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_stores';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_STORES';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_STORES IN EXCLUSIVE MODE;

    FOR r IN (
        WITH ss AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(store_id),     ''), 'UNKNOWN') AS source_store_id,
                COALESCE(NULLIF(TRIM(store_name),   ''), 'UNKNOWN') AS store_name,
                COALESCE(NULLIF(TRIM(store_format), ''), 'UNKNOWN') AS store_format_name,
                COALESCE(NULLIF(TRIM(store_address_country),          ''), 'UNKNOWN') AS country_name,
                COALESCE(NULLIF(TRIM(store_address_region),           ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(store_address_city),             ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(store_address_street),           ''), 'UNKNOWN') AS street,
                COALESCE(NULLIF(TRIM(store_address_house_number),     ''), 'UNKNOWN') AS house_number,
                COALESCE(NULLIF(TRIM(store_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
                COALESCE(NULLIF(TRIM(store_address_postal_code),      ''), 'UNKNOWN') AS postal_code
            FROM sa_offline.src_offline_sales
        )
        SELECT ss.source_store_id, ss.store_name, sf.store_format_id, a.address_id
        FROM ss
        JOIN BL_3NF.LKP_STORE_FORMATS sf
          ON sf.store_format_name = ss.store_format_name
         AND sf.source_system = v_src_sys AND sf.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ADDRESSES a
          ON a.source_address_id = v_src_sys || '|' || v_src_ent || '|' ||
             ss.country_name || '|' || ss.region_name || '|' || ss.city_name || '|' ||
             ss.street || '|' || ss.house_number || '|' || ss.apartment_number || '|' || ss.postal_code
         AND a.source_system = v_src_sys AND a.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_STORES t
            WHERE t.source_store_id = ss.source_store_id
              AND t.source_system   = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY ss.source_store_id
    ) LOOP
        INSERT INTO BL_3NF.CE_STORES (
            store_id, store_name, store_format_id, address_id,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_store_id
        ) VALUES (
            nextval('BL_3NF.seq_address_id'), r.store_name, r.store_format_id, r.address_id,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_src_sys, v_src_ent, r.source_store_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new stores');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_customers_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_customers_online';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_CUSTOMERS';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_CUSTOMERS IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sc AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(customer_id),         ''), 'UNKNOWN') AS source_customer_id,
                COALESCE(NULLIF(TRIM(customer_first_name), ''), 'UNKNOWN') AS first_name,
                COALESCE(NULLIF(TRIM(customer_last_name),  ''), 'UNKNOWN') AS last_name,
                COALESCE(NULLIF(TRIM(customer_email),      ''), 'UNKNOWN') AS email,
                COALESCE(NULLIF(TRIM(customer_phone),      ''), 'UNKNOWN') AS phone,
                COALESCE(NULLIF(TRIM(customer_loyalty_card_number),              ''), 'UNKNOWN') AS loyalty_card_number,
                COALESCE(NULLIF(TRIM(customer_preferred_communication_channel),  ''), 'UNKNOWN') AS comm_channel_name,
                COALESCE(NULLIF(TRIM(customer_registration_date), ''), '1900-01-01') AS registration_raw,
                COALESCE(NULLIF(TRIM(customer_address_country),          ''), 'UNKNOWN') AS country_name,
                COALESCE(NULLIF(TRIM(customer_address_region),           ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(customer_address_city),             ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(customer_address_street),           ''), 'UNKNOWN') AS street,
                COALESCE(NULLIF(TRIM(customer_address_house_number),     ''), 'UNKNOWN') AS house_number,
                COALESCE(NULLIF(TRIM(customer_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
                COALESCE(NULLIF(TRIM(customer_address_postal_code),      ''), 'UNKNOWN') AS postal_code
            FROM sa_online.src_online_sales
        )
        SELECT sc.source_customer_id, sc.first_name, sc.last_name, sc.email, sc.phone,
               sc.loyalty_card_number,
               CASE WHEN sc.registration_raw ~ '^\d{4}-\d{2}-\d{2}'
                    THEN sc.registration_raw::TIMESTAMP
                    ELSE TIMESTAMP '1900-01-01 00:00:00' END AS registration_dt,
               cc.communication_channel_id,
               a.address_id
        FROM sc
        JOIN BL_3NF.LKP_COMMUNICATION_CHANNELS cc
          ON cc.communication_channel_name = sc.comm_channel_name
         AND cc.source_system = v_src_sys AND cc.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ADDRESSES a
          ON a.source_address_id = v_src_sys || '|' || v_src_ent || '|' ||
             sc.country_name || '|' || sc.region_name || '|' || sc.city_name || '|' ||
             sc.street || '|' || sc.house_number || '|' || sc.apartment_number || '|' || sc.postal_code
         AND a.source_system = v_src_sys AND a.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_CUSTOMERS t
            WHERE t.source_customer_id = sc.source_customer_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY sc.source_customer_id
    ) LOOP
        INSERT INTO BL_3NF.CE_CUSTOMERS (
            customer_id, first_name, last_name, email, phone, registration_dt,
            address_id, preferred_communication_channel_id, loyalty_card_number,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
        ) VALUES (
            nextval('BL_3NF.seq_address_id'), r.first_name, r.last_name, r.email, r.phone, r.registration_dt,
            r.address_id, r.communication_channel_id, r.loyalty_card_number,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_src_sys, v_src_ent, r.source_customer_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new customers from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_customers_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_customers_offline';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_CUSTOMERS';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_CUSTOMERS IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sc AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(customer_loyalty_card_number), ''), 'UNKNOWN') AS source_customer_id,
                COALESCE(NULLIF(TRIM(customer_first_name), ''), 'UNKNOWN') AS first_name,
                COALESCE(NULLIF(TRIM(customer_last_name),  ''), 'UNKNOWN') AS last_name,
                COALESCE(NULLIF(TRIM(customer_email),      ''), 'UNKNOWN') AS email,
                COALESCE(NULLIF(TRIM(customer_phone),      ''), 'UNKNOWN') AS phone,
                COALESCE(NULLIF(TRIM(customer_loyalty_card_number),             ''), 'UNKNOWN') AS loyalty_card_number,
                COALESCE(NULLIF(TRIM(customer_preferred_communication_channel), ''), 'UNKNOWN') AS comm_channel_name,
                COALESCE(NULLIF(TRIM(customer_registration_date), ''), '1900-01-01') AS registration_raw,
                COALESCE(NULLIF(TRIM(customer_address_country),          ''), 'UNKNOWN') AS country_name,
                COALESCE(NULLIF(TRIM(customer_address_region),           ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(customer_address_city),             ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(customer_address_street),           ''), 'UNKNOWN') AS street,
                COALESCE(NULLIF(TRIM(customer_address_house_number),     ''), 'UNKNOWN') AS house_number,
                COALESCE(NULLIF(TRIM(customer_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
                COALESCE(NULLIF(TRIM(customer_address_postal_code),      ''), 'UNKNOWN') AS postal_code
            FROM sa_offline.src_offline_sales
        )
        SELECT sc.source_customer_id, sc.first_name, sc.last_name, sc.email, sc.phone,
               sc.loyalty_card_number,
               CASE WHEN sc.registration_raw ~ '^\d{4}-\d{2}-\d{2}'
                    THEN sc.registration_raw::TIMESTAMP
                    ELSE TIMESTAMP '1900-01-01 00:00:00' END AS registration_dt,
               cc.communication_channel_id,
               a.address_id
        FROM sc
        JOIN BL_3NF.LKP_COMMUNICATION_CHANNELS cc
          ON cc.communication_channel_name = sc.comm_channel_name
         AND cc.source_system = v_src_sys AND cc.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ADDRESSES a
          ON a.source_address_id = v_src_sys || '|' || v_src_ent || '|' ||
             sc.country_name || '|' || sc.region_name || '|' || sc.city_name || '|' ||
             sc.street || '|' || sc.house_number || '|' || sc.apartment_number || '|' || sc.postal_code
         AND a.source_system = v_src_sys AND a.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_CUSTOMERS t
            WHERE t.source_customer_id = sc.source_customer_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY sc.source_customer_id
    ) LOOP
        INSERT INTO BL_3NF.CE_CUSTOMERS (
            customer_id, first_name, last_name, email, phone, registration_dt,
            address_id, preferred_communication_channel_id, loyalty_card_number,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
        ) VALUES (
            nextval('BL_3NF.seq_address_id'), r.first_name, r.last_name, r.email, r.phone, r.registration_dt,
            r.address_id, r.communication_channel_id, r.loyalty_card_number,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_src_sys, v_src_ent, r.source_customer_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new customers from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_cashiers()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_cashiers';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_CASHIERS';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_CASHIERS IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sc AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(cashier_id),         ''), 'UNKNOWN') AS source_cashier_id,
                COALESCE(NULLIF(TRIM(cashier_first_name), ''), 'UNKNOWN') AS first_name,
                COALESCE(NULLIF(TRIM(cashier_last_name),  ''), 'UNKNOWN') AS last_name,
                COALESCE(NULLIF(TRIM(cashier_email),      ''), 'UNKNOWN') AS email,
                COALESCE(NULLIF(TRIM(cashier_phone),      ''), 'UNKNOWN') AS phone,
                COALESCE(NULLIF(TRIM(cashier_employment_date), ''), '1900-01-01') AS employment_raw,
                COALESCE(NULLIF(TRIM(cashier_role),       ''), 'UNKNOWN') AS role_name,
                COALESCE(NULLIF(TRIM(cashier_shift_code), ''), 'UNKNOWN') AS shift_name,
                COALESCE(NULLIF(TRIM(cashier_address_country),          ''), 'UNKNOWN') AS country_name,
                COALESCE(NULLIF(TRIM(cashier_address_region),           ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(cashier_address_city),             ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(cashier_address_street),           ''), 'UNKNOWN') AS street,
                COALESCE(NULLIF(TRIM(cashier_address_house_number),     ''), 'UNKNOWN') AS house_number,
                COALESCE(NULLIF(TRIM(cashier_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
                COALESCE(NULLIF(TRIM(cashier_address_postal_code),      ''), 'UNKNOWN') AS postal_code
            FROM sa_offline.src_offline_sales
        )
        SELECT sc.source_cashier_id, sc.first_name, sc.last_name, sc.email, sc.phone,
               CASE WHEN sc.employment_raw ~ '^\d{4}-\d{2}-\d{2}'
                    THEN sc.employment_raw::TIMESTAMP
                    ELSE TIMESTAMP '1900-01-01 00:00:00' END AS employment_dt,
               ro.role_id, sh.shift_id, a.address_id
        FROM sc
        JOIN BL_3NF.LKP_ROLES ro
          ON ro.role_name    = sc.role_name
         AND ro.source_system = v_src_sys AND ro.source_entity = v_src_ent
        JOIN BL_3NF.LKP_SHIFTS sh
          ON sh.shift_name   = sc.shift_name
         AND sh.source_system = v_src_sys AND sh.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ADDRESSES a
          ON a.source_address_id = v_src_sys || '|' || v_src_ent || '|' ||
             sc.country_name || '|' || sc.region_name || '|' || sc.city_name || '|' ||
             sc.street || '|' || sc.house_number || '|' || sc.apartment_number || '|' || sc.postal_code
         AND a.source_system = v_src_sys AND a.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_CASHIERS t
            WHERE t.source_cashier_id = sc.source_cashier_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY sc.source_cashier_id
    ) LOOP
        INSERT INTO BL_3NF.CE_CASHIERS (
            cashier_id, first_name, last_name, email, phone, employment_dt,
            role_id, shift_id, address_id,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_cashier_id
        ) VALUES (
            nextval('BL_3NF.seq_address_id'), r.first_name, r.last_name, r.email, r.phone, r.employment_dt,
            r.role_id, r.shift_id, r.address_id,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_src_sys, v_src_ent, r.source_cashier_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new cashiers');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE BL_CL.load_ce_payments_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_payments_online';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_PAYMENTS';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_PAYMENTS IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sp AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(payment_id),        ''), 'UNKNOWN') AS source_payment_id,
                COALESCE(NULLIF(TRIM(order_id),          ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(payment_method),    ''), 'UNKNOWN') AS payment_method_name,
                COALESCE(NULLIF(TRIM(payment_status),    ''), 'UNKNOWN') AS payment_status_name,
                COALESCE(NULLIF(TRIM(payment_currency),  ''), 'UNKNOWN') AS payment_currency_name,
                COALESCE(NULLIF(TRIM(payment_processor), ''), 'UNKNOWN') AS payment_processor_name,
                COALESCE(NULLIF(TRIM(payment_date),      ''), '1900-01-01') AS payment_date_raw
            FROM sa_online.src_online_sales
        )
        SELECT
            sp.source_payment_id,
            o.order_id,
            pm.payment_method_id,
            ps.payment_status_id,
            pc.payment_currency_id,
            pp.payment_processor_id,
            CASE WHEN sp.payment_date_raw ~ '^\d{4}-\d{2}-\d{2}'
                 THEN sp.payment_date_raw::TIMESTAMP
                 ELSE TIMESTAMP '1900-01-01 00:00:00' END AS payment_dt
        FROM sp
        JOIN BL_3NF.CE_ORDERS o
          ON o.source_order_id = sp.source_order_id
         AND o.source_system   = v_src_sys
         AND o.source_entity   = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_METHODS pm
          ON pm.payment_method_name = sp.payment_method_name
         AND pm.source_system = v_src_sys AND pm.source_entity = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_STATUSES ps
          ON ps.payment_status_name = sp.payment_status_name
         AND ps.source_system = v_src_sys AND ps.source_entity = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_CURRENCIES pc
          ON pc.payment_currency_name = sp.payment_currency_name
         AND pc.source_system = v_src_sys AND pc.source_entity = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_PROCESSORS pp
          ON pp.payment_processor_name = sp.payment_processor_name
         AND pp.source_system = v_src_sys AND pp.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PAYMENTS t
            WHERE t.source_payment_id = sp.source_payment_id
              AND t.source_system     = v_src_sys
              AND t.source_entity     = v_src_ent
        )
        ORDER BY sp.source_payment_id
    ) LOOP
        INSERT INTO BL_3NF.CE_PAYMENTS (
            payment_id, source_payment_id,
            payment_method_id, payment_status_id,
            payment_currency_id, payment_processor_id,
            order_id, payment_dt,
            ta_insert_dt, ta_update_dt,
            source_system, source_entity
        ) VALUES (
            nextval('BL_3NF.seq_payment_id'),
            r.source_payment_id,
            r.payment_method_id, r.payment_status_id,
            r.payment_currency_id, r.payment_processor_id,
            r.order_id, r.payment_dt,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new payments from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE BL_CL.load_ce_payments_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_payments_offline';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_PAYMENTS';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_PAYMENTS IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sp AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(payment_id),        ''), 'UNKNOWN') AS source_payment_id,
                COALESCE(NULLIF(TRIM(order_id),          ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(payment_method),    ''), 'UNKNOWN') AS payment_method_name,
                COALESCE(NULLIF(TRIM(payment_status),    ''), 'UNKNOWN') AS payment_status_name,
                COALESCE(NULLIF(TRIM(payment_currency),  ''), 'UNKNOWN') AS payment_currency_name,
                COALESCE(NULLIF(TRIM(payment_processor), ''), 'UNKNOWN') AS payment_processor_name,
                COALESCE(NULLIF(TRIM(payment_date),      ''), '1900-01-01') AS payment_date_raw
            FROM sa_offline.src_offline_sales
        )
        SELECT
            sp.source_payment_id,
            o.order_id,
            pm.payment_method_id,
            ps.payment_status_id,
            pc.payment_currency_id,
            pp.payment_processor_id,
            CASE WHEN sp.payment_date_raw ~ '^\d{4}-\d{2}-\d{2}'
                 THEN sp.payment_date_raw::TIMESTAMP
                 ELSE TIMESTAMP '1900-01-01 00:00:00' END AS payment_dt
        FROM sp
        JOIN BL_3NF.CE_ORDERS o
          ON o.source_order_id = sp.source_order_id
         AND o.source_system   = v_src_sys
         AND o.source_entity   = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_METHODS pm
          ON pm.payment_method_name = sp.payment_method_name
         AND pm.source_system = v_src_sys AND pm.source_entity = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_STATUSES ps
          ON ps.payment_status_name = sp.payment_status_name
         AND ps.source_system = v_src_sys AND ps.source_entity = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_CURRENCIES pc
          ON pc.payment_currency_name = sp.payment_currency_name
         AND pc.source_system = v_src_sys AND pc.source_entity = v_src_ent
        JOIN BL_3NF.LKP_PAYMENT_PROCESSORS pp
          ON pp.payment_processor_name = sp.payment_processor_name
         AND pp.source_system = v_src_sys AND pp.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_PAYMENTS t
            WHERE t.source_payment_id = sp.source_payment_id
              AND t.source_system     = v_src_sys
              AND t.source_entity     = v_src_ent
        )
        ORDER BY sp.source_payment_id
    ) LOOP
        INSERT INTO BL_3NF.CE_PAYMENTS (
            payment_id, source_payment_id,
            payment_method_id, payment_status_id,
            payment_currency_id, payment_processor_id,
            order_id, payment_dt,
            ta_insert_dt, ta_update_dt,
            source_system, source_entity
        ) VALUES (
            nextval('BL_3NF.seq_payment_id'),
            r.source_payment_id,
            r.payment_method_id, r.payment_status_id,
            r.payment_currency_id, r.payment_processor_id,
            r.order_id, r.payment_dt,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new payments from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_deliveries_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_deliveries_online';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_DELIVERIES';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_DELIVERIES IN EXCLUSIVE MODE;

    FOR r IN (
        WITH sd AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(delivery_id),      ''), 'UNKNOWN') AS source_delivery_id,
                COALESCE(NULLIF(TRIM(order_id),         ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(delivery_status),  ''), 'UNKNOWN') AS delivery_status_name,
                COALESCE(NULLIF(TRIM(delivery_type),    ''), 'UNKNOWN') AS delivery_type_name,
                COALESCE(NULLIF(regexp_replace(
                    COALESCE(NULLIF(TRIM(delivery_shipping_fee), ''), '0'),
                    '[^0-9\.\-]', '', 'g'), ''), '0')::NUMERIC(12,2)   AS shipping_fee,
                COALESCE(NULLIF(TRIM(delivery_date),    ''), '1900-01-01') AS delivery_date_raw,
                COALESCE(NULLIF(TRIM(courier_company),  ''), 'UNKNOWN') AS courier_company_name,
                COALESCE(NULLIF(TRIM(courier_id),       ''), 'UNKNOWN') AS source_courier_id,
                COALESCE(NULLIF(TRIM(warehouse_id),     ''), 'UNKNOWN') AS source_warehouse_id, 
                COALESCE(NULLIF(TRIM(delivery_address_country),          ''), 'UNKNOWN') AS country_name,
                COALESCE(NULLIF(TRIM(delivery_address_region),           ''), 'UNKNOWN') AS region_name,
                COALESCE(NULLIF(TRIM(delivery_address_city),             ''), 'UNKNOWN') AS city_name,
                COALESCE(NULLIF(TRIM(delivery_address_street),           ''), 'UNKNOWN') AS street,
                COALESCE(NULLIF(TRIM(delivery_address_house_number),     ''), 'UNKNOWN') AS house_number,
                COALESCE(NULLIF(TRIM(delivery_address_apartment_number), ''), 'UNKNOWN') AS apartment_number,
                COALESCE(NULLIF(TRIM(delivery_address_postal_code),      ''), 'UNKNOWN') AS postal_code
            FROM sa_online.src_online_sales
        )
        SELECT
            sd.source_delivery_id,
            o.order_id,
            ds.delivery_status_id,
            dt.delivery_type_id,
            sd.shipping_fee,
            CASE WHEN sd.delivery_date_raw ~ '^\d{4}-\d{2}-\d{2}'
                 THEN sd.delivery_date_raw::TIMESTAMP
                 ELSE TIMESTAMP '1900-01-01 00:00:00' END AS delivery_dt,
            cc.courier_company_id, 
            o.order_id AS courier_id_placeholder,
            a.address_id AS delivery_address_id,
            w.warehouse_id
        FROM sd
        JOIN BL_3NF.CE_ORDERS o
          ON o.source_order_id = sd.source_order_id
         AND o.source_system   = v_src_sys
         AND o.source_entity   = v_src_ent
        JOIN BL_3NF.LKP_DELIVERY_STATUSES ds
          ON ds.delivery_status_name = sd.delivery_status_name
         AND ds.source_system = v_src_sys AND ds.source_entity = v_src_ent
        JOIN BL_3NF.LKP_DELIVERY_TYPES dt
          ON dt.delivery_type_name = sd.delivery_type_name
         AND dt.source_system = v_src_sys AND dt.source_entity = v_src_ent
        JOIN BL_3NF.LKP_COURIER_COMPANIES cc
          ON cc.courier_company_name = sd.courier_company_name
         AND cc.source_system = v_src_sys AND cc.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ADDRESSES a
          ON a.source_address_id = v_src_sys || '|' || v_src_ent || '|' ||
             sd.country_name || '|' || sd.region_name || '|' || sd.city_name || '|' ||
             sd.street || '|' || sd.house_number || '|' || sd.apartment_number || '|' || sd.postal_code
         AND a.source_system = v_src_sys AND a.source_entity = v_src_ent
        JOIN BL_3NF.CE_WAREHOUSES w
          ON w.source_warehouse_id = sd.source_warehouse_id
         AND w.source_system = v_src_sys AND w.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_DELIVERIES t
            WHERE t.source_delivery_id = sd.source_delivery_id
              AND t.source_system      = v_src_sys
              AND t.source_entity      = v_src_ent
        )
        ORDER BY sd.source_delivery_id
    ) LOOP
        INSERT INTO BL_3NF.CE_DELIVERIES (
            delivery_id, order_id,
            delivery_status_id, delivery_type_id,
            shipping_fee, delivery_dt,
            courier_company_id, courier_id,
            delivery_address_id, warehouse_id,
            ta_insert_dt, ta_update_dt,
            source_system, source_entity, source_delivery_id
        ) VALUES (
            nextval('BL_3NF.seq_delivery_id'),
            r.order_id,
            r.delivery_status_id, r.delivery_type_id,
            r.shipping_fee, r.delivery_dt,
            r.courier_company_id, r.courier_id_placeholder,
            r.delivery_address_id, r.warehouse_id,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent, r.source_delivery_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new deliveries from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_orders_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows       INT := 0;
    v_proc       CONSTANT VARCHAR := 'BL_CL.load_ce_orders_online';
    v_table      CONSTANT VARCHAR := 'BL_3NF.CE_ORDERS';
    v_src_sys    CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent    CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r            RECORD;
    v_channel_id INT;
BEGIN
    LOCK TABLE BL_3NF.CE_ORDERS IN EXCLUSIVE MODE;

    SELECT channel_id INTO v_channel_id
    FROM BL_3NF.LKP_CHANNELS
    WHERE channel_name  = 'ONLINE'
      AND source_system = v_src_sys
      AND source_entity = v_src_ent;

    FOR r IN (
        WITH so AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(order_id),     ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(customer_id),  ''), 'UNKNOWN') AS source_customer_id,
                COALESCE(NULLIF(TRIM(order_status), ''), 'UNKNOWN') AS order_status_name,
                COALESCE(NULLIF(TRIM(order_date),   ''), '1900-01-01') AS order_date_raw
            FROM sa_online.src_online_sales
        )
        SELECT so.source_order_id, c.customer_id, os.order_status_id,
               CASE WHEN so.order_date_raw ~ '^\d{4}-\d{2}-\d{2}'
                    THEN so.order_date_raw::TIMESTAMP
                    ELSE TIMESTAMP '1900-01-01 00:00:00' END AS order_dt
        FROM so
        JOIN BL_3NF.CE_CUSTOMERS c
          ON c.source_customer_id = so.source_customer_id
         AND c.source_system = v_src_sys AND c.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ORDER_STATUSES os
          ON os.order_status_name = so.order_status_name
         AND os.source_system = v_src_sys AND os.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_ORDERS t
            WHERE t.source_order_id = so.source_order_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY so.source_order_id
    ) LOOP
        INSERT INTO BL_3NF.CE_ORDERS (
            order_id, source_order_id, customer_id, channel_id, order_status_id, order_dt,
            ta_insert_dt, ta_update_dt, source_system, source_entity
        ) VALUES (
            nextval('BL_3NF.seq_order_status_id'), r.source_order_id, r.customer_id, v_channel_id, r.order_status_id, r.order_dt,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_src_sys, v_src_ent
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new orders from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_orders_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows       INT := 0;
    v_proc       CONSTANT VARCHAR := 'BL_CL.load_ce_orders_offline';
    v_table      CONSTANT VARCHAR := 'BL_3NF.CE_ORDERS';
    v_src_sys    CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent    CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r            RECORD;
    v_channel_id INT;
BEGIN
    LOCK TABLE BL_3NF.CE_ORDERS IN EXCLUSIVE MODE;

    SELECT channel_id INTO v_channel_id
    FROM BL_3NF.LKP_CHANNELS
    WHERE channel_name  = 'OFFLINE'
      AND source_system = v_src_sys
      AND source_entity = v_src_ent;

    FOR r IN (
        WITH so AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(order_id),     ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(customer_loyalty_card_number), ''), 'UNKNOWN') AS source_customer_id,
                COALESCE(NULLIF(TRIM(order_status), ''), 'UNKNOWN') AS order_status_name,
                COALESCE(NULLIF(TRIM(order_date),   ''), '1900-01-01') AS order_date_raw
            FROM sa_offline.src_offline_sales
        )
        SELECT so.source_order_id, c.customer_id, os.order_status_id,
               CASE WHEN so.order_date_raw ~ '^\d{4}-\d{2}-\d{2}'
                    THEN so.order_date_raw::TIMESTAMP
                    ELSE TIMESTAMP '1900-01-01 00:00:00' END AS order_dt
        FROM so
        JOIN BL_3NF.CE_CUSTOMERS c
          ON c.source_customer_id = so.source_customer_id
         AND c.source_system = v_src_sys AND c.source_entity = v_src_ent
        JOIN BL_3NF.LKP_ORDER_STATUSES os
          ON os.order_status_name = so.order_status_name
         AND os.source_system = v_src_sys AND os.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_ORDERS t
            WHERE t.source_order_id = so.source_order_id
              AND t.source_system = v_src_sys AND t.source_entity = v_src_ent
        )
        ORDER BY so.source_order_id
    ) LOOP
        INSERT INTO BL_3NF.CE_ORDERS (
            order_id, source_order_id, customer_id, channel_id, order_status_id, order_dt,
            ta_insert_dt, ta_update_dt, source_system, source_entity
        ) VALUES (
            nextval('BL_3NF.seq_order_status_id'), r.source_order_id, r.customer_id, v_channel_id, r.order_status_id, r.order_dt,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_src_sys, v_src_ent
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new orders from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_ce_orders_offline_link()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'BL_CL.load_ce_orders_offline_link';
    v_table   CONSTANT VARCHAR := 'BL_3NF.CE_ORDERS_OFFLINE';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE BL_3NF.CE_ORDERS_OFFLINE IN EXCLUSIVE MODE;

    FOR r IN (
        WITH src AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(order_id),   ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(store_id),   ''), 'UNKNOWN') AS source_store_id,
                COALESCE(NULLIF(TRIM(cashier_id), ''), 'UNKNOWN') AS source_cashier_id
            FROM sa_offline.src_offline_sales
        )
        SELECT o.order_id, s.store_id, ca.cashier_id
        FROM src
        JOIN BL_3NF.CE_ORDERS o
          ON o.source_order_id = src.source_order_id
         AND o.source_system = v_src_sys AND o.source_entity = v_src_ent
        JOIN BL_3NF.CE_STORES s
          ON s.source_store_id = src.source_store_id
         AND s.source_system = v_src_sys AND s.source_entity = v_src_ent
        JOIN BL_3NF.CE_CASHIERS ca
          ON ca.source_cashier_id = src.source_cashier_id
         AND ca.source_system = v_src_sys AND ca.source_entity = v_src_ent
        WHERE NOT EXISTS (
            SELECT 1 FROM BL_3NF.CE_ORDERS_OFFLINE t
            WHERE t.order_id = o.order_id
        )
        ORDER BY o.order_id
    ) LOOP
        INSERT INTO BL_3NF.CE_ORDERS_OFFLINE (order_id, store_id, cashier_id)
        VALUES (r.order_id, r.store_id, r.cashier_id)
        ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new offline order links');
EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE BL_CL.load_all_3nf()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc  CONSTANT VARCHAR := 'BL_CL.load_all_3nf';
    v_start TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    CALL BL_CL.log_load(v_proc, 'ALL', 'ALL', 0, 'INFO', 'Starting full 3NF load');


    INSERT INTO BL_3NF.LKP_CHANNELS (
        channel_id, channel_name, ta_insert_dt, source_system, source_entity, source_channel_id
    )
    SELECT nextval('BL_3NF.seq_channel_id'),
           'ONLINE', CURRENT_TIMESTAMP, 'SA_ONLINE', 'SRC_ONLINE_SALES', 'ONLINE'
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.LKP_CHANNELS
        WHERE channel_name = 'ONLINE' AND source_system = 'SA_ONLINE'
    );

    INSERT INTO BL_3NF.LKP_CHANNELS (
        channel_id, channel_name, ta_insert_dt, source_system, source_entity, source_channel_id
    )
    SELECT nextval('BL_3NF.seq_channel_id'),
           'OFFLINE', CURRENT_TIMESTAMP, 'SA_OFFLINE', 'SRC_OFFLINE_SALES', 'OFFLINE'
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.LKP_CHANNELS
        WHERE channel_name = 'OFFLINE' AND source_system = 'SA_OFFLINE'
    );


    CALL BL_CL.load_lkp_countries_online();
    CALL BL_CL.load_lkp_countries_offline();
    CALL BL_CL.load_lkp_regions_online();
    CALL BL_CL.load_lkp_regions_offline();
    CALL BL_CL.load_lkp_cities_online();
    CALL BL_CL.load_lkp_cities_offline();
    CALL BL_CL.load_lkp_addresses_online();
    CALL BL_CL.load_lkp_addresses_offline();


    CALL BL_CL.load_lkp_communication_channels();
    CALL BL_CL.load_lkp_order_statuses();
    CALL BL_CL.load_lkp_payment_methods();
    CALL BL_CL.load_lkp_payment_statuses();
    CALL BL_CL.load_lkp_payment_currencies();
    CALL BL_CL.load_lkp_payment_processors();
    CALL BL_CL.load_lkp_delivery_statuses();
    CALL BL_CL.load_lkp_delivery_types();
    CALL BL_CL.load_lkp_store_formats();
    CALL BL_CL.load_lkp_warehouse_types();
    CALL BL_CL.load_lkp_courier_companies();
    CALL BL_CL.load_lkp_roles();
    CALL BL_CL.load_lkp_shifts();


    CALL BL_CL.load_ce_product_categories();
    CALL BL_CL.load_ce_product_brands();
    CALL BL_CL.load_ce_products_scd();

    CALL BL_CL.load_ce_warehouses();
    CALL BL_CL.load_ce_stores();

    CALL BL_CL.load_ce_customers_online();
    CALL BL_CL.load_ce_customers_offline();
    CALL BL_CL.load_ce_cashiers();

    CALL BL_CL.load_ce_orders_online();
    CALL BL_CL.load_ce_orders_offline();
    CALL BL_CL.load_ce_orders_offline_link();

    CALL BL_CL.load_ce_payments_online();
    CALL BL_CL.load_ce_payments_offline();
    CALL BL_CL.load_ce_deliveries_online();

    CALL BL_CL.log_load(v_proc, 'ALL', 'ALL', 0, 'INFO',
        'Full 3NF load completed in ' ||
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start))::INT || 's');

EXCEPTION WHEN OTHERS THEN
    CALL BL_CL.log_load(v_proc, 'ALL', 'ALL', 0, 'ERROR',
        'Full 3NF load FAILED: ' || SQLERRM);
    RAISE;
END;
$$;