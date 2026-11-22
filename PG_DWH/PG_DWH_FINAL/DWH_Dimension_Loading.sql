

DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bl_cl_role') THEN
        CREATE ROLE bl_cl_role;
    END IF;
END $$;

GRANT bl_cl_role TO CURRENT_USER;

GRANT USAGE                  ON SCHEMA bl_dm               TO bl_cl_role;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_dm TO bl_cl_role;
GRANT USAGE                  ON ALL SEQUENCES IN SCHEMA bl_dm TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_dm
    GRANT SELECT, INSERT, UPDATE ON TABLES    TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_dm
    GRANT USAGE                  ON SEQUENCES TO bl_cl_role;

GRANT USAGE  ON SCHEMA bl_3nf TO bl_cl_role;
GRANT SELECT ON ALL TABLES IN SCHEMA bl_3nf TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_3nf
    GRANT SELECT ON TABLES TO bl_cl_role;



CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_delivery_id     START 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_warehouse_id    START 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_cashier_id      START 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_customer_id     START 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_order_status_id START 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_store_id        START 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_payment_id      START 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dm_product_id      START 1;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA bl_dm TO bl_cl_role;



DROP TYPE IF EXISTS bl_cl.t_address CASCADE;
CREATE TYPE bl_cl.t_address AS (
    address_id       BIGINT,
    street           VARCHAR,
    house_number     VARCHAR,
    apartment_number VARCHAR,
    postal_code      VARCHAR,
    city_id          BIGINT,
    city_name        VARCHAR,
    region_id        BIGINT,
    region_name      VARCHAR,
    country_id       BIGINT,
    country_code     VARCHAR,
    country_name     VARCHAR
);

CREATE OR REPLACE FUNCTION bl_cl.fn_resolve_address(p_address_id BIGINT)
RETURNS bl_cl.t_address
LANGUAGE plpgsql AS $$
DECLARE
    v_result bl_cl.t_address;
BEGIN
    SELECT
        a.address_id,
        a.street,
        a.house_number,
        a.apartment_number,
        a.postal_code,
        ci.city_id,
        ci.city_name,
        r.region_id,
        r.region_name,
        co.country_id,
        co.country_code,
        co.country_name
    INTO v_result
    FROM bl_3nf.lkp_addresses  a
    JOIN bl_3nf.lkp_cities     ci ON ci.city_id    = a.city_id
    JOIN bl_3nf.lkp_regions    r  ON r.region_id   = ci.region_id
    JOIN bl_3nf.lkp_countries  co ON co.country_id = r.country_id
    WHERE a.address_id = p_address_id
    LIMIT 1;

    IF v_result IS NULL THEN
        v_result.address_id       := -1;
        v_result.street           := 'UNKNOWN';
        v_result.house_number     := 'UNKNOWN';
        v_result.apartment_number := 'UNKNOWN';
        v_result.postal_code      := 'UNKNOWN';
        v_result.city_id          := -1;
        v_result.city_name        := 'UNKNOWN';
        v_result.region_id        := -1;
        v_result.region_name      := 'UNKNOWN';
        v_result.country_id       := -1;
        v_result.country_code     := 'UNKNOWN';
        v_result.country_name     := 'UNKNOWN';
    END IF;

    RETURN v_result;
END;
$$;



CREATE TABLE IF NOT EXISTS bl_cl.load_log (
    log_id         BIGSERIAL    PRIMARY KEY,
    log_dt         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    procedure_name VARCHAR(255) NOT NULL,
    target_table   VARCHAR(255) NOT NULL,
    source_system  VARCHAR(255) NOT NULL,
    rows_affected  INT          NOT NULL DEFAULT 0,
    status         VARCHAR(50)  NOT NULL,
    message        TEXT
);

CREATE OR REPLACE PROCEDURE bl_cl.log_load(
    p_procedure_name VARCHAR,
    p_target_table   VARCHAR,
    p_source_system  VARCHAR,
    p_rows_affected  INT,
    p_status         VARCHAR,
    p_message        TEXT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO bl_cl.load_log (
        log_dt, procedure_name, target_table, source_system,
        rows_affected, status, message
    ) VALUES (
        CURRENT_TIMESTAMP, p_procedure_name, p_target_table,
        p_source_system, p_rows_affected, p_status, p_message
    );
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.load_dim_order_status()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_order_status';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_order_status';
    v_rows     INT := 0;
    v_affected INT := 0;
    r          RECORD;
BEGIN
    INSERT INTO bl_dm.dim_order_status (
        order_status_id, order_status_name, ta_insert_dt,
        source_system, source_entity, source_order_status_id
    ) VALUES (
        -1, 'UNKNOWN', CURRENT_DATE, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN'
    ) ON CONFLICT (order_status_id) DO NOTHING;

    FOR r IN (
        SELECT
            s.order_status_id,
            s.order_status_name,
            s.source_system,
            s.source_entity,
            s.source_status_id
        FROM bl_3nf.lkp_order_statuses s
    ) LOOP
        INSERT INTO bl_dm.dim_order_status (
            order_status_id, order_status_name, ta_insert_dt,
            source_system, source_entity, source_order_status_id
        ) VALUES (
            r.order_status_id,
            r.order_status_name,
            CURRENT_DATE,
            r.source_system,
            r.source_entity,
            r.source_status_id
        )
        ON CONFLICT (order_status_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' new order status rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.load_dim_products_scd()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_products_scd';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_products_scd';
    v_rows     INT := 0;
    v_affected INT := 0;
    r          RECORD;
BEGIN
    INSERT INTO bl_dm.dim_products_scd (
        product_id, product_name, category_id, category_name,
        brand_id, brand_name, product_description, product_price,
        product_country_of_origin_id, country_code, country_name,
        product_margin_rate, ta_start_dt, ta_end_dt, is_active,
        ta_insert_dt, source_system, source_entity, source_product_id
    ) VALUES (
        -1, 'UNKNOWN', -1, 'UNKNOWN', -1, 'UNKNOWN', 'UNKNOWN',
        0, -1, 'UNKNOWN', 'UNKNOWN', 0,
        DATE '1900-01-01', DATE '9999-12-31', FALSE,
        CURRENT_DATE, 'UNKNOWN', 'UNKNOWN', -1
    ) ON CONFLICT (product_id) DO NOTHING;


    UPDATE bl_dm.dim_products_scd dm
    SET    ta_end_dt = src.ta_end_dt,
           is_active = FALSE
    FROM   bl_3nf.ce_products_scd src
    WHERE  dm.product_id  = src.product_id
      AND  src.is_active  = FALSE
      AND  dm.is_active   = TRUE;

   FOR r IN (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        cat.category_name,
        p.brand_id,
        br.brand_name,
        p.product_description,
        p.product_price,
        p.product_country_of_origin_id,
        co.country_code,
        co.country_name,
        p.product_margin_rate,
        p.ta_start_dt::DATE AS ta_start_dt,
        p.ta_end_dt::DATE   AS ta_end_dt,
        p.is_active,
        p.source_system,  
        p.source_entity,   
        p.source_product_id
    FROM bl_3nf.ce_products_scd p
        JOIN bl_3nf.ce_product_categories cat ON cat.category_id = p.category_id
        JOIN bl_3nf.ce_product_brands      br  ON br.brand_id    = p.brand_id
        JOIN bl_3nf.lkp_countries          co  ON co.country_id  = p.product_country_of_origin_id
        WHERE NOT EXISTS (
            SELECT 1 FROM bl_dm.dim_products_scd dm
            WHERE dm.product_id = p.product_id
        )
    ) LOOP
        INSERT INTO bl_dm.dim_products_scd (
            product_id, product_name, category_id, category_name,
            brand_id, brand_name, product_description, product_price,
            product_country_of_origin_id, country_code, country_name,
            product_margin_rate, ta_start_dt, ta_end_dt, is_active,
            ta_insert_dt, source_system, source_entity, source_product_id
        ) VALUES (
            r.product_id, r.product_name, r.category_id, r.category_name,
            r.brand_id, r.brand_name, r.product_description, r.product_price,
            r.product_country_of_origin_id, r.country_code, r.country_name,
            r.product_margin_rate, r.ta_start_dt, r.ta_end_dt, r.is_active,
            CURRENT_DATE,  r.source_system, r.source_entity,  r.source_product_id
        )
        ON CONFLICT (product_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'SCD2: inserted ' || v_rows || ' new product versions into DM');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.load_dim_customers()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_customers';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_customers';
    v_rows     INT := 0;
    v_affected INT := 0;
    r          RECORD;
    v_addr     bl_cl.t_address;
BEGIN
    INSERT INTO bl_dm.dim_customers (
        customer_id, first_name, last_name, email, phone,
        registration_dt, preferred_communication_channel_id,
        preferred_communication_channel_name, loyalty_card_number,
        customer_address_id, street, house_number, apartment_number,
        postal_code, city_id, city_name, region_id, region_name,
        country_id, country_code, country_name,
        ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
    ) VALUES (
        -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
        DATE '1900-01-01', -1, 'UNKNOWN', 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
        'UNKNOWN', -1, 'UNKNOWN', -1, 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN',
        CURRENT_DATE, CURRENT_DATE, 'UNKNOWN', 'UNKNOWN', -1
    ) ON CONFLICT (customer_id) DO NOTHING;

    FOR r IN (
        SELECT
            c.customer_id,
            c.first_name,
            c.last_name,
            c.email,
            c.phone,
            c.registration_dt::DATE                  AS registration_dt,
            c.preferred_communication_channel_id,
            ch.communication_channel_name            AS comm_channel_name,
            c.loyalty_card_number,
            c.address_id,
            c.source_system,
            c.source_entity,
            c.source_customer_id::BIGINT             AS source_customer_id
        FROM bl_3nf.ce_customers c
        LEFT JOIN bl_3nf.lkp_communication_channels ch
               ON ch.communication_channel_id = c.preferred_communication_channel_id
    ) LOOP
        v_addr := bl_cl.fn_resolve_address(r.address_id);

        INSERT INTO bl_dm.dim_customers (
            customer_id, first_name, last_name, email, phone,
            registration_dt, preferred_communication_channel_id,
            preferred_communication_channel_name, loyalty_card_number,
            customer_address_id, street, house_number, apartment_number,
            postal_code, city_id, city_name, region_id, region_name,
            country_id, country_code, country_name,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
        ) VALUES (
            r.customer_id, r.first_name, r.last_name, r.email, r.phone,
            r.registration_dt, r.preferred_communication_channel_id,
            COALESCE(r.comm_channel_name, 'UNKNOWN'), r.loyalty_card_number,
            v_addr.address_id, v_addr.street, v_addr.house_number, v_addr.apartment_number,
            v_addr.postal_code, v_addr.city_id, v_addr.city_name,
            v_addr.region_id, v_addr.region_name,
            v_addr.country_id, v_addr.country_code, v_addr.country_name,
            CURRENT_DATE, CURRENT_DATE, r.source_system, r.source_entity, r.source_customer_id
        )
        ON CONFLICT (customer_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' new customer rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;
 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_cashiers()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_cashiers';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_cashiers';
    v_rows     INT := 0;
    v_affected INT := 0;
    r          RECORD;
    v_addr     bl_cl.t_address;
BEGIN
    INSERT INTO bl_dm.dim_cashiers (
        cashier_id, first_name, last_name, email, phone, employment_dt,
        role_id, role_name, shift_id, shift_name,
        cashier_address_id, street, house_number, apartment_number,
        postal_code, city_id, city_name, region_id, region_name,
        country_id, country_code, country_name,
        ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
    ) VALUES (
        -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', DATE '1900-01-01',
        -1, 'UNKNOWN', -1, 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
        'UNKNOWN', -1, 'UNKNOWN', -1, 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN',
        CURRENT_DATE, CURRENT_DATE, 'UNKNOWN', 'UNKNOWN', -1
    ) ON CONFLICT (cashier_id) DO NOTHING;

    FOR r IN (
        SELECT
            ca.cashier_id,
            ca.first_name,
            ca.last_name,
            ca.email,
            ca.phone,
            ca.employment_dt::DATE           AS employment_dt,
            ca.role_id,
            ro.role_name,
            ca.shift_id,
            sh.shift_name,
            ca.address_id,
            ca.source_system,
            ca.source_entity,
            ca.source_cashier_id::BIGINT     AS source_cashier_id
        FROM bl_3nf.ce_cashiers ca
        LEFT JOIN bl_3nf.lkp_roles  ro ON ro.role_id  = ca.role_id
        LEFT JOIN bl_3nf.lkp_shifts sh ON sh.shift_id = ca.shift_id
    ) LOOP
        v_addr := bl_cl.fn_resolve_address(r.address_id);

        INSERT INTO bl_dm.dim_cashiers (
            cashier_id, first_name, last_name, email, phone, employment_dt,
            role_id, role_name, shift_id, shift_name,
            cashier_address_id, street, house_number, apartment_number,
            postal_code, city_id, city_name, region_id, region_name,
            country_id, country_code, country_name,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
        ) VALUES (
            r.cashier_id, r.first_name, r.last_name, r.email, r.phone, r.employment_dt,
            r.role_id, COALESCE(r.role_name,  'UNKNOWN'),
            r.shift_id, COALESCE(r.shift_name, 'UNKNOWN'),
            v_addr.address_id, v_addr.street, v_addr.house_number, v_addr.apartment_number,
            v_addr.postal_code, v_addr.city_id, v_addr.city_name,
            v_addr.region_id, v_addr.region_name,
            v_addr.country_id, v_addr.country_code, v_addr.country_name,
            CURRENT_DATE, CURRENT_DATE, r.source_system, r.source_entity, r.source_cashier_id
        )
        ON CONFLICT (cashier_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' new cashier rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_stores()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_stores';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_stores';
    v_rows     INT := 0;
    v_affected INT := 0;
    r          RECORD;
    v_addr     bl_cl.t_address;
BEGIN
    INSERT INTO bl_dm.dim_stores (
        store_id, store_name, store_format_id, store_format_name,
        store_address_id, street, house_number, apartment_number,
        postal_code, city_id, city_name, region_id, region_name,
        country_id, country_code, country_name,
        ta_insert_dt, ta_update_dt, source_system, source_entity, source_store_id
    ) VALUES (
        -1, 'UNKNOWN', -1, 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
        'UNKNOWN', -1, 'UNKNOWN', -1, 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN',
        CURRENT_DATE, CURRENT_DATE, 'UNKNOWN', 'UNKNOWN', -1
    ) ON CONFLICT (store_id) DO NOTHING;

    FOR r IN (
        SELECT
            s.store_id,
            s.store_name,
            s.store_format_id,
            sf.store_format_name,
            s.address_id,
            s.source_system,
            s.source_entity,
            s.source_store_id::BIGINT AS source_store_id
        FROM bl_3nf.ce_stores s
        LEFT JOIN bl_3nf.lkp_store_formats sf ON sf.store_format_id = s.store_format_id
    ) LOOP
        v_addr := bl_cl.fn_resolve_address(r.address_id);

        INSERT INTO bl_dm.dim_stores (
            store_id, store_name, store_format_id, store_format_name,
            store_address_id, street, house_number, apartment_number,
            postal_code, city_id, city_name, region_id, region_name,
            country_id, country_code, country_name,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_store_id
        ) VALUES (
            r.store_id, r.store_name, r.store_format_id,
            COALESCE(r.store_format_name, 'UNKNOWN'),
            v_addr.address_id, v_addr.street, v_addr.house_number, v_addr.apartment_number,
            v_addr.postal_code, v_addr.city_id, v_addr.city_name,
            v_addr.region_id, v_addr.region_name,
            v_addr.country_id, v_addr.country_code, v_addr.country_name,
            CURRENT_DATE, CURRENT_DATE, r.source_system, r.source_entity, r.source_store_id
        )
        ON CONFLICT (store_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' new store rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;
 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_warehouses()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_warehouses';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_warehouses';
    v_rows     INT := 0;
    v_affected INT := 0;
    r          RECORD;
    v_addr     bl_cl.t_address;
BEGIN
    INSERT INTO bl_dm.dim_warehouses (
        warehouse_id, warehouse_type_id, warehouse_type_name,
        num_employees, capacity_units,
        address_id, street, house_number, apartment_number,
        postal_code, city_id, city_name, region_id, region_name,
        country_id, country_code, country_name,
        ta_insert_dt, ta_update_dt, source_system, source_entity, source_warehouse_id
    ) VALUES (
        -1, -1, 'UNKNOWN', -1, -1,
        -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
        'UNKNOWN', -1, 'UNKNOWN', -1, 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN',
        CURRENT_DATE, CURRENT_DATE, 'UNKNOWN', 'UNKNOWN', -1
    ) ON CONFLICT (warehouse_id) DO NOTHING;

    FOR r IN (
        SELECT
            w.warehouse_id,
            w.warehouse_type_id,
            wt.warehouse_type_name,
            w.num_employees,
            w.capacity_units,
            w.address_id,
            w.source_system,
            w.source_entity,
            w.source_warehouse_id::BIGINT AS source_warehouse_id
        FROM bl_3nf.ce_warehouses w
        LEFT JOIN bl_3nf.lkp_warehouse_types wt ON wt.warehouse_type_id = w.warehouse_type_id
    ) LOOP
        v_addr := bl_cl.fn_resolve_address(r.address_id);

        INSERT INTO bl_dm.dim_warehouses (
            warehouse_id, warehouse_type_id, warehouse_type_name,
            num_employees, capacity_units,
            address_id, street, house_number, apartment_number,
            postal_code, city_id, city_name, region_id, region_name,
            country_id, country_code, country_name,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_warehouse_id
        ) VALUES (
            r.warehouse_id, r.warehouse_type_id,
            COALESCE(r.warehouse_type_name, 'UNKNOWN'),
            r.num_employees, r.capacity_units,
            v_addr.address_id, v_addr.street, v_addr.house_number, v_addr.apartment_number,
            v_addr.postal_code, v_addr.city_id, v_addr.city_name,
            v_addr.region_id, v_addr.region_name,
            v_addr.country_id, v_addr.country_code, v_addr.country_name,
            CURRENT_DATE, CURRENT_DATE, r.source_system, r.source_entity, r.source_warehouse_id
        )
        ON CONFLICT (warehouse_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' new warehouse rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;
 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_payments()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_payments';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_payments';
    v_rows     INT := 0;
    v_affected INT := 0;
    v_cursor   REFCURSOR;
    r          RECORD;
BEGIN
    INSERT INTO bl_dm.dim_payments (
        payment_id, payment_method_id, payment_method_name,
        payment_status_id, payment_status_name,
        payment_currency_id, payment_currency_name,
        payment_processor_id, payment_processor_name,
        payment_dt, ta_insert_dt, ta_update_dt,
        source_system, source_entity, source_payment_id
    ) VALUES (
        -1, -1, 'UNKNOWN', -1, 'UNKNOWN', -1, 'UNKNOWN', -1, 'UNKNOWN',
        DATE '1900-01-01', CURRENT_DATE, CURRENT_DATE,
        'UNKNOWN', 'UNKNOWN', 'UNKNOWN'
    ) ON CONFLICT (payment_id) DO NOTHING;


    OPEN v_cursor FOR
        SELECT
            p.payment_id,
            p.payment_method_id,
            pm.payment_method_name,
            p.payment_status_id,
            ps.payment_status_name,
            p.payment_currency_id,
            pc.payment_currency_name,
            p.payment_processor_id,
            pp.payment_processor_name,
            p.payment_dt::DATE  AS payment_dt,
            p.source_system,
            p.source_entity,
            p.source_payment_id
        FROM bl_3nf.ce_payments p
        LEFT JOIN bl_3nf.lkp_payment_methods    pm ON pm.payment_method_id    = p.payment_method_id
        LEFT JOIN bl_3nf.lkp_payment_statuses   ps ON ps.payment_status_id    = p.payment_status_id
        LEFT JOIN bl_3nf.lkp_payment_currencies pc ON pc.payment_currency_id  = p.payment_currency_id
        LEFT JOIN bl_3nf.lkp_payment_processors pp ON pp.payment_processor_id = p.payment_processor_id;

    LOOP
        FETCH v_cursor INTO r;
        EXIT WHEN NOT FOUND;

        INSERT INTO bl_dm.dim_payments (
            payment_id, payment_method_id, payment_method_name,
            payment_status_id, payment_status_name,
            payment_currency_id, payment_currency_name,
            payment_processor_id, payment_processor_name,
            payment_dt, ta_insert_dt, ta_update_dt,
            source_system, source_entity, source_payment_id
        ) VALUES (
            r.payment_id,
            r.payment_method_id,    COALESCE(r.payment_method_name,    'UNKNOWN'),
            r.payment_status_id,    COALESCE(r.payment_status_name,    'UNKNOWN'),
            r.payment_currency_id,  COALESCE(r.payment_currency_name,  'UNKNOWN'),
            r.payment_processor_id, COALESCE(r.payment_processor_name, 'UNKNOWN'),
            r.payment_dt, CURRENT_DATE, CURRENT_DATE,
            r.source_system, r.source_entity, r.source_payment_id
        )
        ON CONFLICT (payment_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CLOSE v_cursor;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' new payment rows');
EXCEPTION WHEN OTHERS THEN
    IF v_cursor IS NOT NULL THEN CLOSE v_cursor; END IF;
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_deliveries()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_deliveries';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_deliveries';
    v_rows     INT := 0;
    v_affected INT := 0;
    r          RECORD;
    v_addr     bl_cl.t_address;
BEGIN
    INSERT INTO bl_dm.dim_deliveries (
        delivery_id, delivery_status_id, delivery_status_name,
        delivery_type_id, delivery_type_name, delivery_dt,
        courier_company_id, courier_company_name,
        delivery_address_id, courier_id,
        street, house_number, apartment_number, postal_code,
        city_id, city_name, region_id, region_name,
        country_id, country_code, country_name,
        ta_insert_dt, ta_update_dt, source_system, source_entity, source_delivery_id
    ) VALUES (
        -1, -1, 'UNKNOWN', -1, 'UNKNOWN', DATE '1900-01-01',
        -1, 'UNKNOWN', -1, -1,
        'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
        -1, 'UNKNOWN', -1, 'UNKNOWN',
        -1, 'UNKNOWN', 'UNKNOWN',
        CURRENT_DATE, CURRENT_DATE, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN'
    ) ON CONFLICT (delivery_id) DO NOTHING;

    FOR r IN (
        SELECT
            d.delivery_id,
            d.delivery_status_id,
            ds.delivery_status_name,
            d.delivery_type_id,
            dt.delivery_type_name,
            d.delivery_dt::DATE           AS delivery_dt,
            d.courier_company_id,
            cc.courier_company_name,
            d.delivery_address_id,         
            d.courier_id,
            d.source_system,
            d.source_entity,
            d.source_delivery_id
        FROM bl_3nf.ce_deliveries d
        LEFT JOIN bl_3nf.lkp_delivery_statuses ds ON ds.delivery_status_id = d.delivery_status_id
        LEFT JOIN bl_3nf.lkp_delivery_types    dt ON dt.delivery_type_id   = d.delivery_type_id
        LEFT JOIN bl_3nf.lkp_courier_companies cc ON cc.courier_company_id = d.courier_company_id
    ) LOOP
        v_addr := bl_cl.fn_resolve_address(r.delivery_address_id);

        INSERT INTO bl_dm.dim_deliveries (
            delivery_id, delivery_status_id, delivery_status_name,
            delivery_type_id, delivery_type_name, delivery_dt,
            courier_company_id, courier_company_name,
            delivery_address_id, courier_id,
            street, house_number, apartment_number, postal_code,
            city_id, city_name, region_id, region_name,
            country_id, country_code, country_name,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_delivery_id
        ) VALUES (
            r.delivery_id,
            r.delivery_status_id,  COALESCE(r.delivery_status_name,  'UNKNOWN'),
            r.delivery_type_id,    COALESCE(r.delivery_type_name,    'UNKNOWN'),
            r.delivery_dt,
            r.courier_company_id,  COALESCE(r.courier_company_name,  'UNKNOWN'),
            v_addr.address_id, r.courier_id,
            v_addr.street, v_addr.house_number, v_addr.apartment_number, v_addr.postal_code,
            v_addr.city_id, v_addr.city_name,
            v_addr.region_id, v_addr.region_name,
            v_addr.country_id, v_addr.country_code, v_addr.country_name,
            CURRENT_DATE, CURRENT_DATE, r.source_system, r.source_entity, r.source_delivery_id
        )
        ON CONFLICT (delivery_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' new delivery rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'BL_3NF', 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;
 
CREATE OR REPLACE PROCEDURE bl_cl.load_dim_dates()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc     CONSTANT VARCHAR := 'bl_cl.load_dim_dates';
    v_table    CONSTANT VARCHAR := 'bl_dm.dim_dates';
    v_rows     INT := 0;
    v_min_date DATE;
    v_max_date DATE;
    v_sql      TEXT;
BEGIN 
    INSERT INTO bl_dm.dim_dates (
        date_id, full_date, day_of_week, day_name, week_of_year,
        month, month_name, quarter, year, is_weekend, is_holiday
    ) VALUES (
        -1, DATE '1900-01-01', -1, 'UNKNOWN', -1,
        -1, 'UNKNOWN', -1, -1, FALSE, FALSE
    ) ON CONFLICT (date_id) DO NOTHING;
 
    SELECT
        LEAST(MIN(order_dt::DATE),   DATE '2024-01-01'),
        GREATEST(MAX(order_dt::DATE), DATE '2026-01-31')
    INTO v_min_date, v_max_date
    FROM bl_3nf.ce_orders
    WHERE order_dt > TIMESTAMP '1900-01-01';
 
    v_sql := $sql$
        INSERT INTO bl_dm.dim_dates (
            date_id, full_date, day_of_week, day_name, week_of_year,
            month, month_name, quarter, year, is_weekend, is_holiday
        )
        SELECT
            TO_CHAR(d, 'YYYYMMDD')::BIGINT          AS date_id,
            d                                        AS full_date,
            EXTRACT(ISODOW  FROM d)::BIGINT          AS day_of_week,
            TO_CHAR(d, 'FMDay')                      AS day_name,
            EXTRACT(WEEK    FROM d)::BIGINT          AS week_of_year,
            EXTRACT(MONTH   FROM d)::BIGINT          AS month,
            TO_CHAR(d, 'FMMonth')                    AS month_name,
            EXTRACT(QUARTER FROM d)::BIGINT          AS quarter,
            EXTRACT(YEAR    FROM d)::BIGINT          AS year,
            CASE WHEN EXTRACT(ISODOW FROM d) IN (6,7)
                 THEN TRUE ELSE FALSE END            AS is_weekend,
            FALSE                                    AS is_holiday
        FROM generate_series($1::DATE, $2::DATE, '1 day'::INTERVAL) AS d
        ON CONFLICT (date_id) DO NOTHING
    $sql$;

    EXECUTE v_sql USING v_min_date, v_max_date;
    GET DIAGNOSTICS v_rows = ROW_COUNT;
 
    UPDATE bl_dm.dim_dates
    SET    is_holiday = FALSE
    WHERE  full_date BETWEEN v_min_date AND v_max_date;
 
    UPDATE bl_dm.dim_dates
    SET    is_holiday = TRUE
    WHERE  full_date IN (
        -- 2024
        DATE '2024-01-01',  -- New Year's Day
        DATE '2024-02-16',  -- Restoration of the State of Lithuania
        DATE '2024-03-11',  -- Restoration of Independence
        DATE '2024-03-31',  -- Easter Sunday
        DATE '2024-04-01',  -- Easter Monday
        DATE '2024-05-01',  -- Labour Day
        DATE '2024-05-05',  -- Mother's Day
        DATE '2024-06-02',  -- Father's Day
        DATE '2024-06-24',  -- Joninės (Midsummer)
        DATE '2024-07-06',  -- Statehood Day
        DATE '2024-08-15',  -- Assumption
        DATE '2024-11-01',  -- All Saints' Day
        DATE '2024-11-02',  -- All Souls' Day
        DATE '2024-12-24',  -- Christmas Eve
        DATE '2024-12-25',  -- Christmas Day
        DATE '2024-12-26',  -- Second Day of Christmas
        -- 2025
        DATE '2025-01-01',  -- New Year's Day
        DATE '2025-02-16',  -- Restoration of the State of Lithuania
        DATE '2025-03-11',  -- Restoration of Independence
        DATE '2025-04-20',  -- Easter Sunday
        DATE '2025-04-21',  -- Easter Monday
        DATE '2025-05-01',  -- Labour Day
        DATE '2025-05-04',  -- Mother's Day
        DATE '2025-06-01',  -- Father's Day
        DATE '2025-06-24',  -- Joninės (Midsummer)
        DATE '2025-07-06',  -- Statehood Day
        DATE '2025-08-15',  -- Assumption
        DATE '2025-11-01',  -- All Saints' Day
        DATE '2025-11-02',  -- All Souls' Day
        DATE '2025-12-24',  -- Christmas Eve
        DATE '2025-12-25',  -- Christmas Day
        DATE '2025-12-26',  -- Second Day of Christmas
        -- 2026
        DATE '2026-01-01'   -- New Year's Day
    );

    CALL bl_cl.log_load(v_proc, v_table, 'GENERATED', v_rows, 'SUCCESS',
        'Generated dates ' || v_min_date || ' → ' || v_max_date
        || ' | ' || v_rows || ' new rows inserted');

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'GENERATED', 0, 'ERROR', SQLERRM);
    RAISE;
END;
 

CREATE OR REPLACE PROCEDURE bl_cl.load_all_dm_dims()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc  CONSTANT VARCHAR := 'bl_cl.load_all_dm_dims';
    v_start TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'INFO',
        'Starting BL_DM dimension load');

    CALL bl_cl.load_dim_dates();
    CALL bl_cl.load_dim_order_status();
    CALL bl_cl.load_dim_products_scd();
    CALL bl_cl.load_dim_customers();
    CALL bl_cl.load_dim_cashiers();
    CALL bl_cl.load_dim_stores();
    CALL bl_cl.load_dim_warehouses();
    CALL bl_cl.load_dim_payments();
    CALL bl_cl.load_dim_deliveries();

    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'INFO',
        'BL_DM dimension load completed in '
        || EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start))::INT || 's');

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'ERROR',
        'BL_DM dimension load FAILED: ' || SQLERRM);
    RAISE;
END;
$$;

