CREATE FOREIGN TABLE IF NOT EXISTS sa_online.ext_online_sales (
 order_id varchar,
 customer_id varchar,
 product_id varchar,
 payment_id varchar,
 delivery_id varchar,
 warehouse_id varchar,
 courier_id varchar,
 customer_first_name varchar,
 customer_last_name varchar,
 customer_email varchar,
 customer_phone varchar,
 customer_registration_date varchar,
 customer_loyalty_card_number varchar,
 customer_preferred_communication_channel varchar,
 customer_address_country varchar,
 customer_address_region varchar,
 customer_address_city varchar,
 customer_address_street varchar,
 customer_address_house_number varchar,
 customer_address_apartment_number varchar,
 customer_address_postal_code varchar,
 product_name varchar,
 product_category varchar,
 product_price varchar,
 product_stock_quantity varchar,
 product_description varchar,
 product_country_of_origin varchar,
 product_margin_rate varchar,
 product_brand varchar,
 order_date varchar,
 order_status varchar,
 order_total_amount varchar,
 order_item_quantity varchar,
 order_item_discount_amount varchar,
 payment_method varchar,
 payment_amount_paid varchar,
 payment_date varchar,
 payment_status varchar,
 payment_currency varchar,
 payment_processor varchar,
 courier_company varchar,
 delivery_status varchar,
 delivery_shipping_fee varchar,
 delivery_date varchar,
 delivery_type varchar,
 delivery_address_country varchar,
 delivery_address_region varchar,
 delivery_address_city varchar,
  delivery_address_street varchar,
  delivery_address_house_number varchar,
  delivery_address_apartment_number varchar,
  delivery_address_postal_code varchar,
  warehouse_num_employees varchar,
  warehouse_capacity_units varchar,
  warehouse_type varchar,
  warehouse_address_country varchar,
  warehouse_address_region varchar,
  warehouse_address_city varchar,
  warehouse_address_street varchar,
  warehouse_address_house_number varchar,
  warehouse_address_apartment_number varchar,
  warehouse_address_postal_code varchar
)
SERVER file_server
OPTIONS (
  filename 'C:/postgres_files/source_online_sales.csv',
  format 'csv',
  header 'true',
  delimiter ','
);

SELECT * FROM sa_online.ext_online_sales LIMIT 10;





----------------------------------

CREATE TABLE IF NOT EXISTS sa_online.src_online_sales (
 LIKE sa_online.ext_online_sales INCLUDING ALL
);

ALTER TABLE sa_online.src_online_sales
ADD COLUMN IF NOT EXISTS ta_insert_dt timestamp NOT NULL DEFAULT now();

TRUNCATE TABLE sa_online.src_online_sales;

INSERT INTO sa_online.src_online_sales
SELECT distinct *
FROM sa_online.ext_online_sales;

SELECT * FROM sa_online.src_online_sales LIMIT 10;


--------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SCHEMA IF NOT EXISTS sa_offline;

CREATE SERVER IF NOT EXISTS file_server
FOREIGN DATA WRAPPER file_fdw;

DROP FOREIGN TABLE IF EXISTS sa_offline.ext_offline_sales;

CREATE FOREIGN TABLE sa_offline.ext_offline_sales (

 order_id varchar,
 product_id varchar,
 payment_id varchar,
 store_id varchar,
 cashier_id varchar,

 customer_loyalty_card_number varchar,
 customer_first_name varchar,
 customer_last_name varchar,
 customer_email varchar,
 customer_phone varchar,
 customer_registration_date varchar,
 customer_preferred_communication_channel varchar,

 customer_address_country varchar,
 customer_address_region varchar,
 customer_address_city varchar,
 customer_address_street varchar,
 customer_address_house_number varchar,
 customer_address_apartment_number varchar,
 customer_address_postal_code varchar,

 product_name varchar,
 product_category varchar,
 product_price varchar,
 product_stock_quantity varchar,
 product_description varchar,
 product_country_of_origin varchar,
 product_margin_rate varchar,
 product_brand varchar,

 order_date varchar,
 order_status varchar,
 order_total_amount varchar,
 order_item_quantity varchar,
 order_item_discount_amount varchar,

 payment_method varchar,
  payment_amount_paid varchar,
  payment_date varchar,
  payment_status varchar,
  payment_currency varchar,
  payment_processor varchar,

  store_name varchar,
  store_format varchar,
  store_region varchar,

  store_address_country varchar,
  store_address_region varchar,
  store_address_city varchar,
  store_address_street varchar,
  store_address_house_number varchar,
  store_address_apartment_number varchar,
  store_address_postal_code varchar,

  cashier_first_name varchar,
  cashier_last_name varchar,
  cashier_email varchar,
  cashier_phone varchar,
  cashier_employment_date varchar,
  cashier_role varchar,
  cashier_shift_code varchar,

  cashier_address_country varchar,
  cashier_address_region varchar,
  cashier_address_city varchar,
  cashier_address_street varchar,
  cashier_address_house_number varchar,
  cashier_address_apartment_number varchar,
  cashier_address_postal_code varchar

)
SERVER file_server
OPTIONS (
  filename 'C:/postgres_files/source_offline_sales.csv',
  format 'csv',
  header 'true',
  delimiter ','
);



SELECT * FROM sa_offline.ext_offline_sales LIMIT 10;


-----------------------------------------
CREATE TABLE IF NOT EXISTS sa_offline.src_offline_sales (
 LIKE sa_offline.ext_offline_sales INCLUDING ALL
);

ALTER TABLE sa_offline.src_offline_sales
ADD COLUMN IF NOT EXISTS ta_insert_dt timestamp NOT NULL DEFAULT now();

TRUNCATE TABLE sa_offline.src_offline_sales;

INSERT INTO sa_offline.src_offline_sales
SELECT distinct *
FROM sa_offline.ext_offline_sales;

SELECT * FROM sa_offline.src_offline_sales LIMIT 20;