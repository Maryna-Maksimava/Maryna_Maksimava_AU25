
BEGIN;
INSERT INTO bl_dm.dim_deliveries (
  delivery_id, delivery_status_id, delivery_status_name, delivery_type_id, delivery_type_name,
  delivery_dt, courier_company_id, courier_company_name, delivery_address_id, courier_id,
  street, house_number, apartment_number, postal_code,
  city_id, city_name, region_id, region_name, country_id, country_code, country_name,
  ta_insert_dt, ta_update_dt, source_system, source_entity, source_delivery_id
)
SELECT
  -1, -1, 'UNKNOWN', -1, 'UNKNOWN',
  DATE '1900-01-01', -1, 'UNKNOWN', -1, -1,
  'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',
  -1,'UNKNOWN', -1,'UNKNOWN', -1,'UNKNOWN','UNKNOWN',
  DATE '1900-01-01', DATE '1900-01-01', 'UNKNOWN','UNKNOWN','UNKNOWN'
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_deliveries WHERE delivery_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_warehouses (
  warehouse_id, warehouse_type_id, warehouse_type_name, num_employees, capacity_units,
  address_id, street, house_number, apartment_number, postal_code,
  city_id, city_name, region_id, region_name, country_id, country_code, country_name,
  ta_insert_dt, ta_update_dt, source_system, source_entity, source_warehouse_id
)
SELECT
  -1, -1, 'UNKNOWN', -1, -1,
  -1, 'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',
  -1,'UNKNOWN', -1,'UNKNOWN', -1,'UNKNOWN','UNKNOWN',
  DATE '1900-01-01', DATE '1900-01-01', 'UNKNOWN','UNKNOWN', -1
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_warehouses WHERE warehouse_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_cashiers (
  cashier_id, first_name, last_name, email, phone, employment_dt,
  role_id, role_name, shift_id, shift_name,
  cashier_address_id, street, house_number, apartment_number, postal_code,
  city_id, city_name, region_id, region_name, country_id, country_code, country_name,
  ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
)
SELECT
  -1,'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN', DATE '1900-01-01',
  -1,'UNKNOWN', -1,'UNKNOWN',
  -1,'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',
  -1,'UNKNOWN', -1,'UNKNOWN', -1,'UNKNOWN','UNKNOWN',
  DATE '1900-01-01', DATE '1900-01-01', 'UNKNOWN','UNKNOWN', -1
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_cashiers WHERE cashier_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_customers (
  customer_id, first_name, last_name, email, phone, registration_dt,
  preferred_communication_channel_id, preferred_communication_channel_name,
  loyalty_card_number, customer_address_id,
  street, house_number, apartment_number, postal_code,
  city_id, city_name, region_id, region_name, country_id, country_code, country_name,
  ta_insert_dt, ta_update_dt, source_system, source_entity, source_customer_id
)
SELECT
  -1,'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN', DATE '1900-01-01',
  -1,'UNKNOWN', 'UNKNOWN', -1,
  'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',
  -1,'UNKNOWN', -1,'UNKNOWN', -1,'UNKNOWN','UNKNOWN',
  DATE '1900-01-01', DATE '1900-01-01', 'UNKNOWN','UNKNOWN', -1
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_customers WHERE customer_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_order_status (
  order_status_id, order_status_name, ta_insert_dt, source_system, source_entity, source_order_status_id
)
SELECT
  -1, 'UNKNOWN', DATE '1900-01-01', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN'
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_order_status WHERE order_status_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_stores (
  store_id, store_name, store_format_id, store_format_name, store_address_id,
  street, house_number, apartment_number, postal_code,
  city_id, city_name, region_id, region_name, country_id, country_code, country_name,
  ta_insert_dt, ta_update_dt, source_system, source_entity, source_store_id
)
SELECT
  -1,'UNKNOWN', -1,'UNKNOWN', -1,
  'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',
  -1,'UNKNOWN', -1,'UNKNOWN', -1,'UNKNOWN','UNKNOWN',
  DATE '1900-01-01', DATE '1900-01-01', 'UNKNOWN','UNKNOWN', -1
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_stores WHERE store_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_payments (
  payment_id, payment_method_id, payment_method_name,
  payment_status_id, payment_status_name,
  payment_currency_id, payment_currency_name,
  payment_processor_id, payment_processor_name,
  payment_dt, ta_insert_dt, ta_update_dt,
  source_system, source_entity, source_payment_id
)
SELECT
  -1, -1,'UNKNOWN',
  -1,'UNKNOWN',
  -1,'UNKNOWN',
  -1,'UNKNOWN',
  DATE '1900-01-01', DATE '1900-01-01', DATE '1900-01-01',
  'UNKNOWN','UNKNOWN','UNKNOWN'
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_payments WHERE payment_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_dates (
  date_id, full_date, day_of_week, day_name, week_of_year, month, month_name, quarter, year, is_weekend, is_holiday
)
SELECT
  -1, DATE '1900-01-01', 'UNKNOWN','UNKNOWN', -1, -1,'UNKNOWN', -1, -1, FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_dates WHERE date_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.dim_products_scd (
  product_id, product_name, category_id, category_name, brand_id, brand_name,
  product_description, product_price, product_country_of_origin_id,
  country_code, country_name, product_margin_rate,
  ta_start_dt, ta_end_dt, is_active, ta_insert_dt,
  source_system, source_entity, source_product_id
)
SELECT
  -1,'UNKNOWN', -1,'UNKNOWN', -1,'UNKNOWN',
  'UNKNOWN', 0, -1,
  'UNKNOWN','UNKNOWN', 0,
  DATE '1900-01-01', DATE '9999-12-31', FALSE, DATE '1900-01-01',
  -1, -1, 'UNKNOWN'
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_products_scd WHERE product_id = -1);
COMMIT;

BEGIN;
INSERT INTO bl_dm.fact_order_items (
  order_id, product_id, customer_id, order_date_id, payment_id, order_status_id,
  quantity, discount_amount, order_items_amount, order_items_amount_after_discount,
  delivery_id, store_id, cashier_id, warehouse_id
)
SELECT
  -1, -1, -1, -1, -1, -1,
  0, 0, 0, 0,
  -1, -1, -1, -1
WHERE NOT EXISTS (
  SELECT 1 FROM bl_dm.fact_order_items WHERE order_id = -1 AND product_id = -1
);
COMMIT;