
DROP TABLE IF EXISTS bl_dm.fact_order_items CASCADE; 
CREATE TABLE bl_dm.fact_order_items (
    order_id                              BIGINT  NOT NULL DEFAULT -1,
  product_id                            BIGINT  NOT NULL DEFAULT -1,
  customer_id                           BIGINT  NOT NULL DEFAULT -1,
  order_date_id                         BIGINT  NOT NULL DEFAULT -1,
  payment_id                            BIGINT  NOT NULL DEFAULT -1,
  order_status_id                       BIGINT  NOT NULL DEFAULT -1,
  quantity                              BIGINT  NOT NULL DEFAULT 0,
  discount_amount                       DECIMAL(12,2)  NOT NULL DEFAULT 0,
  order_items_amount                    DECIMAL(12,2)  NOT NULL DEFAULT 0,
  order_items_amount_after_discount     DECIMAL(12,2)  NOT NULL DEFAULT 0,
  delivery_id                           BIGINT  NOT NULL DEFAULT -1,
  store_id                              BIGINT  NOT NULL DEFAULT -1,
  cashier_id                            BIGINT  NOT NULL DEFAULT -1,
  warehouse_id                          BIGINT  NOT NULL DEFAULT -1,
    PRIMARY KEY (order_id, product_id, order_date_id)
) PARTITION BY RANGE (order_date_id);

CREATE TABLE IF NOT EXISTS bl_dm.fact_order_items_default
    PARTITION OF bl_dm.fact_order_items DEFAULT;


CREATE OR REPLACE PROCEDURE bl_cl.create_fact_partition(
    p_year  INT,
    p_month INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_partition_name  VARCHAR;
    v_date_from       BIGINT;
    v_date_to         BIGINT;
    v_month_start     DATE;
    v_month_end       DATE;
    v_exists          BOOLEAN;
BEGIN
    v_partition_name := 'fact_order_items_' || p_year || '_' || LPAD(p_month::TEXT, 2, '0');
    v_month_start    := DATE (p_year || '-' || LPAD(p_month::TEXT, 2, '0') || '-01');
    v_month_end      := v_month_start + INTERVAL '1 month';
    v_date_from      := TO_CHAR(v_month_start, 'YYYYMMDD')::BIGINT;
    v_date_to        := TO_CHAR(v_month_end,   'YYYYMMDD')::BIGINT;

		--check if it exists already
    SELECT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'bl_dm'
          AND c.relname = v_partition_name
    ) INTO v_exists;

    IF NOT v_exists THEN
        EXECUTE format(
            'CREATE TABLE bl_dm.%I (
                LIKE bl_dm.fact_order_items INCLUDING DEFAULTS
            )',
            v_partition_name
        );

        RAISE NOTICE 'Created partition: bl_dm.%', v_partition_name;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.attach_fact_partition(
    p_year  INT,
    p_month INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_partition_name VARCHAR;
    v_date_from      BIGINT;
    v_date_to        BIGINT;
    v_month_start    DATE;
    v_month_end      DATE;
    v_is_attached    BOOLEAN;
BEGIN
    v_partition_name := 'fact_order_items_' || p_year || '_' || LPAD(p_month::TEXT, 2, '0');
    v_month_start    := DATE (p_year || '-' || LPAD(p_month::TEXT, 2, '0') || '-01');
    v_month_end      := v_month_start + INTERVAL '1 month';
    v_date_from      := TO_CHAR(v_month_start, 'YYYYMMDD')::BIGINT;
    v_date_to        := TO_CHAR(v_month_end,   'YYYYMMDD')::BIGINT;

    --check if it is already attached 
    SELECT EXISTS (
        SELECT 1 FROM pg_inherits i
        JOIN pg_class parent ON parent.oid = i.inhparent
        JOIN pg_class child  ON child.oid  = i.inhrelid
        JOIN pg_namespace pn ON pn.oid = parent.relnamespace
        JOIN pg_namespace cn ON cn.oid = child.relnamespace
        WHERE pn.nspname = 'bl_dm' AND parent.relname = 'fact_order_items'
          AND cn.nspname = 'bl_dm' AND child.relname  = v_partition_name
    ) INTO v_is_attached;

    IF NOT v_is_attached THEN
        EXECUTE format(
            'ALTER TABLE bl_dm.fact_order_items
             ATTACH PARTITION bl_dm.%I
             FOR VALUES FROM (%L) TO (%L)',
            v_partition_name,
            v_date_from,
            v_date_to
        );
        RAISE NOTICE 'Attached partition: bl_dm.% [% → %)',
            v_partition_name, v_date_from, v_date_to;
    ELSE
        RAISE NOTICE 'Partition already attached: bl_dm.%', v_partition_name;
    END IF;
END;
$$; 


CREATE OR REPLACE PROCEDURE bl_cl.detach_fact_partition(
    p_year  INT,
    p_month INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_partition_name VARCHAR;
    v_is_attached    BOOLEAN;
BEGIN
    v_partition_name := 'fact_order_items_' || p_year || '_' || LPAD(p_month::TEXT, 2, '0');

    SELECT EXISTS (
        SELECT 1 FROM pg_inherits i
        JOIN pg_class parent ON parent.oid = i.inhparent
        JOIN pg_class child  ON child.oid  = i.inhrelid
        JOIN pg_namespace pn ON pn.oid = parent.relnamespace
        JOIN pg_namespace cn ON cn.oid = child.relnamespace
        WHERE pn.nspname = 'bl_dm' AND parent.relname = 'fact_order_items'
          AND cn.nspname = 'bl_dm' AND child.relname  = v_partition_name
    ) INTO v_is_attached;

    IF v_is_attached THEN
        EXECUTE format(
            'ALTER TABLE bl_dm.fact_order_items
             DETACH PARTITION bl_dm.%I',
            v_partition_name
        );
        RAISE NOTICE 'Detached partition: bl_dm.% (data preserved)', v_partition_name;
    ELSE
        RAISE NOTICE 'Partition not attached (skipping detach): bl_dm.%', v_partition_name;
    END IF;
END;
$$;
 
CREATE OR REPLACE PROCEDURE bl_cl.load_fact_order_items_month(
    p_year  INT,
    p_month INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_proc           CONSTANT VARCHAR := 'bl_cl.load_fact_order_items_month';
    v_table          CONSTANT VARCHAR := 'bl_dm.fact_order_items';
    v_partition_name VARCHAR;
    v_date_from      BIGINT;
    v_date_to        BIGINT;
    v_month_start    DATE;
    v_month_end      DATE;
    v_rows           INT := 0;
    v_affected       INT := 0;
    r                RECORD;
BEGIN
    v_partition_name := 'fact_order_items_' || p_year || '_' || LPAD(p_month::TEXT, 2, '0');
    v_month_start    := DATE (p_year || '-' || LPAD(p_month::TEXT, 2, '0') || '-01');
    v_month_end      := v_month_start + INTERVAL '1 month';
    v_date_from      := TO_CHAR(v_month_start, 'YYYYMMDD')::BIGINT;
    v_date_to        := TO_CHAR(v_month_end,   'YYYYMMDD')::BIGINT;

    CALL bl_cl.log_load(v_proc, v_table,
        p_year || '-' || LPAD(p_month::TEXT, 2, '0'), 0, 'INFO',
        'Loading fact rows for ' || v_month_start || ' → ' || v_month_end);
 
    FOR r IN (
        SELECT 
            oi.order_id, 
            COALESCE(
                (SELECT p.product_id
                 FROM bl_3nf.ce_products_scd p
                 WHERE p.source_product_id = src_p.source_product_id
                   AND p.source_system     = src_p.source_system
                   AND p.source_entity     = src_p.source_entity
                   AND p.is_active         = TRUE
                 LIMIT 1),
                -1
            )                                           AS product_id,
            COALESCE(o.customer_id,        -1)          AS customer_id, 
            TO_CHAR(o.order_dt, 'YYYYMMDD')::BIGINT    AS order_date_id, 
            COALESCE(pay.payment_id,       -1)          AS payment_id,
            COALESCE(o.order_status_id,    -1)          AS order_status_id, 
            oi.quantity,
            oi.discount_amount,
            oi.order_item_amount                        AS order_items_amount,
            (oi.order_item_amount - oi.discount_amount) AS order_items_amount_after_discount, 
            COALESCE(del.delivery_id,      -1)          AS delivery_id,
            COALESCE(ofl.store_id,         -1)          AS store_id,
            COALESCE(ofl.cashier_id,       -1)          AS cashier_id,
            COALESCE(wh_link.warehouse_id, -1)          AS warehouse_id
        FROM bl_3nf.ce_order_items oi 
        JOIN bl_3nf.ce_orders o
          ON o.order_id = oi.order_id 
        JOIN bl_3nf.ce_products_scd src_p
          ON src_p.product_id = oi.product_id 
        LEFT JOIN bl_3nf.ce_payments pay
          ON pay.order_id = o.order_id 
        LEFT JOIN bl_3nf.ce_deliveries del
          ON del.order_id = o.order_id 
        LEFT JOIN bl_3nf.ce_orders_offline ofl
          ON ofl.order_id = o.order_id 
        LEFT JOIN bl_3nf.ce_warehouses wh_link
          ON wh_link.warehouse_id = del.warehouse_id 
        WHERE o.order_dt >= v_month_start::TIMESTAMP
          AND o.order_dt <  v_month_end::TIMESTAMP
    ) LOOP
        INSERT INTO bl_dm.fact_order_items (
            order_id, product_id, customer_id, order_date_id,
            payment_id, order_status_id,
            quantity, discount_amount,
            order_items_amount, order_items_amount_after_discount,
            delivery_id, store_id, cashier_id, warehouse_id
        ) VALUES (
            r.order_id, r.product_id, r.customer_id, r.order_date_id,
            r.payment_id, r.order_status_id,
            r.quantity, r.discount_amount,
            r.order_items_amount, r.order_items_amount_after_discount,
            r.delivery_id, r.store_id, r.cashier_id, r.warehouse_id
        )
        ON CONFLICT (order_id, product_id, order_date_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_rows := v_rows + v_affected;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table,
        p_year || '-' || LPAD(p_month::TEXT, 2, '0'), v_rows, 'SUCCESS',
        'Inserted ' || v_rows || ' fact rows for '
        || p_year || '-' || LPAD(p_month::TEXT, 2, '0'));

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table,
        p_year || '-' || LPAD(p_month::TEXT, 2, '0'), 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;

 
CREATE OR REPLACE PROCEDURE bl_cl.load_fact_rolling_window()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc       CONSTANT VARCHAR := 'bl_cl.load_fact_rolling_window';
    v_table      CONSTANT VARCHAR := 'bl_dm.fact_order_items';
    v_start      TIMESTAMP := CURRENT_TIMESTAMP;
 
    v_window_months  INT := 3;
    v_current_date   DATE := DATE_TRUNC('month', CURRENT_DATE);
 
    v_target_date    DATE;
    v_year           INT;
    v_month          INT;
 
    v_partition_name VARCHAR;
    v_cutoff_date    DATE;
    part             RECORD;
    v_part_year      INT;
    v_part_month     INT;
    
    
    v_min_date       DATE;
    v_rows_default   INT := 0;
BEGIN

    v_min_date := v_current_date - ((v_window_months - 1) || ' months')::INTERVAL;

    CALL bl_cl.log_load(v_proc, v_table, 'ROLLING_WINDOW', 0, 'INFO',
        'Starting rolling window fact load — window: '
        || v_min_date || ' → ' || (v_current_date + INTERVAL '1 month - 1 day')::DATE);
 
 
    FOR i IN 0 .. v_window_months - 1 LOOP 
        v_target_date := v_current_date - (i || ' months')::INTERVAL;
        v_year        := EXTRACT(YEAR  FROM v_target_date)::INT;
        v_month       := EXTRACT(MONTH FROM v_target_date)::INT;

        RAISE NOTICE 'Processing window month: %-% ', v_year, LPAD(v_month::TEXT,2,'0');
 
        CALL bl_cl.create_fact_partition(v_year, v_month);
        CALL bl_cl.attach_fact_partition(v_year, v_month);
        CALL bl_cl.load_fact_order_items_month(v_year, v_month);
    END LOOP;


    RAISE NOTICE 'Loading historical data (older than %) into DEFAULT partition...', v_min_date;

    INSERT INTO bl_dm.fact_order_items (
        order_id, product_id, customer_id, order_date_id,
        payment_id, order_status_id, quantity, discount_amount,
        order_items_amount, order_items_amount_after_discount,
        delivery_id, store_id, cashier_id, warehouse_id
    )
    SELECT 
        oi.order_id, 
        COALESCE(
            (SELECT p.product_id
             FROM bl_3nf.ce_products_scd p
             WHERE p.product_id = oi.product_id -- Assuming internal ID link
               AND p.is_active  = TRUE
             LIMIT 1), -1)                              AS product_id,
        COALESCE(o.customer_id,        -1)              AS customer_id, 
        TO_CHAR(o.order_dt, 'YYYYMMDD')::BIGINT        AS order_date_id, 
        COALESCE(pay.payment_id,       -1)              AS payment_id,
        COALESCE(o.order_status_id,    -1)              AS order_status_id, 
        oi.quantity,
        oi.discount_amount,
        oi.order_item_amount                            AS order_items_amount,
        (oi.order_item_amount - oi.discount_amount)     AS order_items_amount_after_discount, 
        COALESCE(del.delivery_id,      -1)              AS delivery_id,
        COALESCE(ofl.store_id,         -1)              AS store_id,
        COALESCE(ofl.cashier_id,       -1)              AS cashier_id,
        COALESCE(wh_link.warehouse_id, -1)              AS warehouse_id
    FROM bl_3nf.ce_order_items oi 
    JOIN bl_3nf.ce_orders o ON o.order_id = oi.order_id 
    LEFT JOIN bl_3nf.ce_payments pay ON pay.order_id = o.order_id 
    LEFT JOIN bl_3nf.ce_deliveries del ON del.order_id = o.order_id 
    LEFT JOIN bl_3nf.ce_orders_offline ofl ON ofl.order_id = o.order_id 
    LEFT JOIN bl_3nf.ce_warehouses wh_link ON wh_link.warehouse_id = del.warehouse_id 
    WHERE o.order_dt < v_min_date::TIMESTAMP  -- This directs rows to the DEFAULT partition
    ON CONFLICT (order_id, product_id, order_date_id) DO NOTHING;

    GET DIAGNOSTICS v_rows_default = ROW_COUNT;
    RAISE NOTICE 'Inserted % historical rows into default partition.', v_rows_default;


    v_cutoff_date := v_min_date;
 
    FOR part IN (
        SELECT child.relname AS partition_name
        FROM pg_inherits i
        JOIN pg_class parent ON parent.oid = i.inhparent
        JOIN pg_class child  ON child.oid  = i.inhrelid
        JOIN pg_namespace pn ON pn.oid = parent.relnamespace
        JOIN pg_namespace cn ON cn.oid = child.relnamespace
        WHERE pn.nspname = 'bl_dm'
          AND parent.relname = 'fact_order_items'
          AND child.relname  != 'fact_order_items_default'
          AND child.relname  LIKE 'fact_order_items_%'
    ) LOOP 
        BEGIN
            v_part_year  := SPLIT_PART(part.partition_name, '_', 4)::INT;
            v_part_month := SPLIT_PART(part.partition_name, '_', 5)::INT;
            
            IF DATE(v_part_year || '-' || LPAD(v_part_month::TEXT,2,'0') || '-01') < v_cutoff_date THEN
                RAISE NOTICE 'Detaching old partition: %', part.partition_name;
                CALL bl_cl.detach_fact_partition(v_part_year, v_part_month);
            END IF;
        EXCEPTION WHEN OTHERS THEN
            CONTINUE; 
        END;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, 'ROLLING_WINDOW', v_rows_default, 'SUCCESS',
        'Rolling window fact load completed. Total historical rows: ' || v_rows_default);

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, 'ROLLING_WINDOW', 0, 'ERROR',
        'Rolling window fact load FAILED: ' || SQLERRM);
    RAISE;
END;
$$;
call bl_cl.load_fact_rolling_window();
select * from bl_dm.fact_order_items;

