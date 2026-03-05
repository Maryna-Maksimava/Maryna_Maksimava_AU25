
CREATE OR REPLACE PROCEDURE bl_cl.load_ce_order_items_online()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'bl_cl.load_ce_order_items_online';
    v_table   CONSTANT VARCHAR := 'bl_3nf.ce_order_items';
    v_src_sys CONSTANT VARCHAR := 'SA_ONLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_ONLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE bl_3nf.ce_order_items IN EXCLUSIVE MODE;

    FOR r IN (
        WITH src_items AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(order_id),   ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(product_id), ''), 'UNKNOWN') AS source_product_id,
                COALESCE(NULLIF(regexp_replace(
                    COALESCE(NULLIF(TRIM(order_item_quantity),       ''), '0'), '[^0-9\-]',   '', 'g'), ''), '0')::INT            AS quantity,
                COALESCE(NULLIF(regexp_replace(
                    COALESCE(NULLIF(TRIM(order_total_amount),        ''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::NUMERIC(12,2) AS order_item_amount,
                COALESCE(NULLIF(regexp_replace(
                    COALESCE(NULLIF(TRIM(order_item_discount_amount),''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::NUMERIC(12,2) AS discount_amount
            FROM sa_online.src_online_sales
        ),
        order_map AS (
            SELECT order_id, source_order_id
            FROM bl_3nf.ce_orders
            WHERE source_system = v_src_sys AND source_entity = v_src_ent
        ),
        product_map AS (
            SELECT source_product_id, MIN(product_id) AS product_id
            FROM bl_3nf.ce_products_scd
            WHERE source_system = v_src_sys AND source_entity = v_src_ent
              AND is_active = TRUE
            GROUP BY source_product_id
        )
        SELECT
            om.order_id,
            pm.product_id,
            si.quantity,
            si.order_item_amount,
            si.discount_amount,
            (si.source_order_id || '|' || si.source_product_id) AS source_order_item_id
        FROM src_items si
        JOIN order_map   om ON om.source_order_id   = si.source_order_id
        JOIN product_map pm ON pm.source_product_id = si.source_product_id
        WHERE NOT EXISTS (
            SELECT 1 FROM bl_3nf.ce_order_items t
            WHERE t.order_id   = om.order_id
              AND t.product_id = pm.product_id
        )
        ORDER BY om.order_id, pm.product_id
    ) LOOP
        INSERT INTO bl_3nf.ce_order_items (
            order_id, product_id, quantity, order_item_amount, discount_amount,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_order_item_id
        ) VALUES (
            r.order_id, r.product_id, r.quantity, r.order_item_amount, r.discount_amount,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent, r.source_order_item_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new order items from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE bl_cl.load_ce_order_items_offline()
LANGUAGE plpgsql AS $$
DECLARE
    v_rows    INT := 0;
    v_proc    CONSTANT VARCHAR := 'bl_cl.load_ce_order_items_offline';
    v_table   CONSTANT VARCHAR := 'bl_3nf.ce_order_items';
    v_src_sys CONSTANT VARCHAR := 'SA_OFFLINE';
    v_src_ent CONSTANT VARCHAR := 'SRC_OFFLINE_SALES';
    r         RECORD;
BEGIN
    LOCK TABLE bl_3nf.ce_order_items IN EXCLUSIVE MODE;

    FOR r IN (
        WITH src_items AS (
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(order_id),   ''), 'UNKNOWN') AS source_order_id,
                COALESCE(NULLIF(TRIM(product_id), ''), 'UNKNOWN') AS source_product_id,
                COALESCE(NULLIF(regexp_replace(
                    COALESCE(NULLIF(TRIM(order_item_quantity),       ''), '0'), '[^0-9\-]',   '', 'g'), ''), '0')::INT            AS quantity,
                COALESCE(NULLIF(regexp_replace(
                    COALESCE(NULLIF(TRIM(order_total_amount),        ''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::NUMERIC(12,2) AS order_item_amount,
                COALESCE(NULLIF(regexp_replace(
                    COALESCE(NULLIF(TRIM(order_item_discount_amount),''), '0'), '[^0-9\.\-]', '', 'g'), ''), '0')::NUMERIC(12,2) AS discount_amount
            FROM sa_offline.src_offline_sales
        ),
        order_map AS (
            SELECT order_id, source_order_id
            FROM bl_3nf.ce_orders
            WHERE source_system = v_src_sys AND source_entity = v_src_ent
        ),
        product_map AS (
            SELECT source_product_id, MIN(product_id) AS product_id
            FROM bl_3nf.ce_products_scd
            WHERE source_system = v_src_sys AND source_entity = v_src_ent
              AND is_active = TRUE
            GROUP BY source_product_id
        )
        SELECT
            om.order_id,
            pm.product_id,
            si.quantity,
            si.order_item_amount,
            si.discount_amount,
            (si.source_order_id || '|' || si.source_product_id) AS source_order_item_id
        FROM src_items si
        JOIN order_map   om ON om.source_order_id   = si.source_order_id
        JOIN product_map pm ON pm.source_product_id = si.source_product_id
        WHERE NOT EXISTS (
            SELECT 1 FROM bl_3nf.ce_order_items t
            WHERE t.order_id   = om.order_id
              AND t.product_id = pm.product_id
        )
        ORDER BY om.order_id, pm.product_id
    ) LOOP
        INSERT INTO bl_3nf.ce_order_items (
            order_id, product_id, quantity, order_item_amount, discount_amount,
            ta_insert_dt, ta_update_dt, source_system, source_entity, source_order_item_id
        ) VALUES (
            r.order_id, r.product_id, r.quantity, r.order_item_amount, r.discount_amount,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
            v_src_sys, v_src_ent, r.source_order_item_id
        ) ON CONFLICT DO NOTHING;
        v_rows := v_rows + 1;
    END LOOP;

    CALL bl_cl.log_load(v_proc, v_table, v_src_sys, v_rows, 'SUCCESS',
        'Loaded ' || v_rows || ' new order items from ' || v_src_sys);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, v_table, v_src_sys, 0, 'ERROR', SQLERRM);
    RAISE;
END;
$$;




CREATE OR REPLACE PROCEDURE bl_cl.load_all_3nf()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc  CONSTANT VARCHAR := 'bl_cl.load_all_3nf';
    v_start TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    CALL bl_cl.log_load(v_proc, 'ALL', 'ALL', 0, 'INFO', 'Starting full 3NF load');

    -- Channels
    INSERT INTO bl_3nf.lkp_channels (
        channel_id, channel_name, ta_insert_dt, source_system, source_entity, source_channel_id
    )
    SELECT nextval('bl_3nf.seq_channel_id'),
           'ONLINE', CURRENT_TIMESTAMP, 'SA_ONLINE', 'SRC_ONLINE_SALES', 'ONLINE'
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.lkp_channels
        WHERE channel_name = 'ONLINE' AND source_system = 'SA_ONLINE'
    );
    INSERT INTO bl_3nf.lkp_channels (
        channel_id, channel_name, ta_insert_dt, source_system, source_entity, source_channel_id
    )
    SELECT nextval('bl_3nf.seq_channel_id'),
           'OFFLINE', CURRENT_TIMESTAMP, 'SA_OFFLINE', 'SRC_OFFLINE_SALES', 'OFFLINE'
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_3nf.lkp_channels
        WHERE channel_name = 'OFFLINE' AND source_system = 'SA_OFFLINE'
    );
 
    CALL bl_cl.load_lkp_countries_online();
    CALL bl_cl.load_lkp_countries_offline();
    CALL bl_cl.load_lkp_regions_online();
    CALL bl_cl.load_lkp_regions_offline();
    CALL bl_cl.load_lkp_cities_online();
    CALL bl_cl.load_lkp_cities_offline();
    CALL bl_cl.load_lkp_addresses_online();
    CALL bl_cl.load_lkp_addresses_offline();
 
    CALL bl_cl.load_lkp_communication_channels();
    CALL bl_cl.load_lkp_order_statuses();
    CALL bl_cl.load_lkp_payment_methods();
    CALL bl_cl.load_lkp_payment_statuses();
    CALL bl_cl.load_lkp_payment_currencies();
    CALL bl_cl.load_lkp_payment_processors();
    CALL bl_cl.load_lkp_delivery_statuses();
    CALL bl_cl.load_lkp_delivery_types();
    CALL bl_cl.load_lkp_store_formats();
    CALL bl_cl.load_lkp_warehouse_types();
    CALL bl_cl.load_lkp_courier_companies();
    CALL bl_cl.load_lkp_roles();
    CALL bl_cl.load_lkp_shifts();
 
    CALL bl_cl.load_ce_product_categories();
    CALL bl_cl.load_ce_product_brands();
    CALL bl_cl.load_ce_products_scd();
 
    CALL bl_cl.load_ce_warehouses();
    CALL bl_cl.load_ce_stores();
 
    CALL bl_cl.load_ce_customers_online();
    CALL bl_cl.load_ce_customers_offline();
    CALL bl_cl.load_ce_cashiers();
 
    CALL bl_cl.load_ce_orders_online();
    CALL bl_cl.load_ce_orders_offline();
    CALL bl_cl.load_ce_orders_offline_link();
 
    CALL bl_cl.load_ce_payments_online();
    CALL bl_cl.load_ce_payments_offline();
    CALL bl_cl.load_ce_deliveries_online();
 
    CALL bl_cl.load_ce_order_items_online();
    CALL bl_cl.load_ce_order_items_offline();

    CALL bl_cl.log_load(v_proc, 'ALL', 'ALL', 0, 'INFO',
        'Full 3NF load completed in ' ||
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start))::INT || 's');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, 'ALL', 'ALL', 0, 'ERROR',
        'Full 3NF load FAILED: ' || SQLERRM);
    RAISE;
END;
$$;
 
CREATE OR REPLACE PROCEDURE bl_cl.load_all_dm_dims()
LANGUAGE plpgsql AS $$
DECLARE
    v_proc  CONSTANT VARCHAR := 'bl_cl.load_all_dm_dims';
    v_start TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'INFO',
        'Starting BL_DM load');
 
    CALL bl_cl.load_dim_dates();
    CALL bl_cl.load_dim_order_status();
    CALL bl_cl.load_dim_products_scd();
    CALL bl_cl.load_dim_customers();
    CALL bl_cl.load_dim_cashiers();
    CALL bl_cl.load_dim_stores();
    CALL bl_cl.load_dim_warehouses();
    CALL bl_cl.load_dim_payments();
    CALL bl_cl.load_dim_deliveries();
    CALL bl_cl.load_fact_rolling_window()


    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'INFO',
        'BL_DM load completed in '
        || EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start))::INT || 's');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'ERROR',
        'BL_DM load FAILED: ' || SQLERRM);
    RAISE;
END;
$$;

