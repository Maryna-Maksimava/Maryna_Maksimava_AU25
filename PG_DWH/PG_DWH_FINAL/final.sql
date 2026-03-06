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

--------------------------------------------------------------------------------



DROP SCHEMA IF EXISTS bl_3nf CASCADE;
CREATE SCHEMA bl_3nf;
SET search_path TO bl_3nf;



CREATE SEQUENCE bl_3nf.seq_country_id       START 1;
CREATE SEQUENCE bl_3nf.seq_region_id        START 1;
CREATE SEQUENCE bl_3nf.seq_city_id          START 1;
CREATE SEQUENCE bl_3nf.seq_address_id       START 1;
CREATE SEQUENCE bl_3nf.seq_comm_channel_id  START 1;
CREATE SEQUENCE bl_3nf.seq_order_status_id  START 1;
CREATE SEQUENCE bl_3nf.seq_pay_method_id    START 1;
CREATE SEQUENCE bl_3nf.seq_pay_status_id    START 1;
CREATE SEQUENCE bl_3nf.seq_pay_currency_id  START 1;
CREATE SEQUENCE bl_3nf.seq_pay_processor_id START 1;
CREATE SEQUENCE bl_3nf.seq_del_status_id    START 1;
CREATE SEQUENCE bl_3nf.seq_del_type_id      START 1;
CREATE SEQUENCE bl_3nf.seq_store_format_id  START 1;
CREATE SEQUENCE bl_3nf.seq_wh_type_id       START 1;
CREATE SEQUENCE bl_3nf.seq_courier_id       START 1;
CREATE SEQUENCE bl_3nf.seq_role_id          START 1;
CREATE SEQUENCE bl_3nf.seq_shift_id         START 1;
CREATE SEQUENCE bl_3nf.seq_channel_id       START 1;
CREATE SEQUENCE bl_3nf.seq_category_id      START 1;
CREATE SEQUENCE bl_3nf.seq_brand_id         START 1;
CREATE SEQUENCE bl_3nf.seq_product_id       START 1;
CREATE SEQUENCE bl_3nf.seq_warehouse_id     START 1;
CREATE SEQUENCE bl_3nf.seq_store_id         START 1;
CREATE SEQUENCE bl_3nf.seq_customer_id      START 1;
CREATE SEQUENCE bl_3nf.seq_cashier_id       START 1;
CREATE SEQUENCE bl_3nf.seq_order_id         START 1;
CREATE SEQUENCE bl_3nf.seq_payment_id       START 1;
CREATE SEQUENCE bl_3nf.seq_delivery_id      START 1;



CREATE TABLE bl_3nf.lkp_communication_channels (
    communication_channel_id   INT          PRIMARY KEY,
    communication_channel_name VARCHAR(255) NOT NULL,
    ta_insert_dt               TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system              VARCHAR(255) NOT NULL,
    source_entity              VARCHAR(255) NOT NULL,
    source_communication_channel_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_roles (
    role_id        INT          PRIMARY KEY,
    role_name      VARCHAR(255) NOT NULL,
    ta_insert_dt   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system  VARCHAR(255) NOT NULL,
    source_entity  VARCHAR(255) NOT NULL,
    source_role_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_shifts (
    shift_id        INT          PRIMARY KEY,
    shift_name      VARCHAR(255) NOT NULL,
    ta_insert_dt    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system   VARCHAR(255) NOT NULL,
    source_entity   VARCHAR(255) NOT NULL,
    source_shift_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_countries (
    country_id     INT          PRIMARY KEY,
    country_code   VARCHAR(255) NOT NULL,
    country_name   VARCHAR(255) NOT NULL,
    ta_insert_dt   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system  VARCHAR(255) NOT NULL,
    source_entity  VARCHAR(255) NOT NULL,
    src_country_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_order_statuses (
    order_status_id   INT          PRIMARY KEY,
    order_status_name VARCHAR(255) NOT NULL,
    ta_insert_dt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system     VARCHAR(255) NOT NULL,
    source_entity     VARCHAR(255) NOT NULL,
    source_status_id  VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_payment_statuses (
    payment_status_id        INT          PRIMARY KEY,
    payment_status_name      VARCHAR(255) NOT NULL,
    ta_insert_dt             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system            VARCHAR(255) NOT NULL,
    source_entity            VARCHAR(255) NOT NULL,
    source_payment_status_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_payment_methods (
    payment_method_id        INT          PRIMARY KEY,
    payment_method_name      VARCHAR(255) NOT NULL,
    ta_insert_dt             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system            VARCHAR(255) NOT NULL,
    source_entity            VARCHAR(255) NOT NULL,
    source_payment_method_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_payment_currencies (
    payment_currency_id        INT          PRIMARY KEY,
    payment_currency_name      VARCHAR(255) NOT NULL,
    ta_insert_dt               TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system              VARCHAR(255) NOT NULL,
    source_entity              VARCHAR(255) NOT NULL,
    source_payment_currency_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_payment_processors (
    payment_processor_id        INT          PRIMARY KEY,
    payment_processor_name      VARCHAR(255) NOT NULL,
    ta_insert_dt                TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system               VARCHAR(255) NOT NULL,
    source_entity               VARCHAR(255) NOT NULL,
    source_payment_processor_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_delivery_statuses (
    delivery_status_id        INT          PRIMARY KEY,
    delivery_status_name      VARCHAR(255) NOT NULL,
    ta_insert_dt              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system             VARCHAR(255) NOT NULL,
    source_entity             VARCHAR(255) NOT NULL,
    source_delivery_status_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_delivery_types (
    delivery_type_id        INT          PRIMARY KEY,
    delivery_type_name      VARCHAR(255) NOT NULL,
    ta_insert_dt            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system           VARCHAR(255) NOT NULL,
    source_entity           VARCHAR(255) NOT NULL,
    source_delivery_type_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_store_formats (
    store_format_id        INT          PRIMARY KEY,
    store_format_name      VARCHAR(255) NOT NULL,
    ta_insert_dt           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system          VARCHAR(255) NOT NULL,
    source_entity          VARCHAR(255) NOT NULL,
    source_store_format_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_warehouse_types (
    warehouse_type_id        INT          PRIMARY KEY,
    warehouse_type_name      VARCHAR(255) NOT NULL,
    ta_insert_dt             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system            VARCHAR(255) NOT NULL,
    source_entity            VARCHAR(255) NOT NULL,
    source_warehouse_type_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.lkp_courier_companies (
    courier_company_id        INT          PRIMARY KEY,
    courier_company_name      VARCHAR(255) NOT NULL,
    ta_insert_dt              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system             VARCHAR(255) NOT NULL,
    source_entity             VARCHAR(255) NOT NULL,
    source_courier_company_id VARCHAR(255) NOT NULL
);


CREATE TABLE bl_3nf.lkp_channels (
    channel_id        INT          PRIMARY KEY,
    channel_name      VARCHAR(255) NOT NULL,
    ta_insert_dt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system     VARCHAR(255) NOT NULL,
    source_entity     VARCHAR(255) NOT NULL,
    source_channel_id VARCHAR(255) NOT NULL
);




CREATE TABLE bl_3nf.lkp_regions (
    region_id        INT          PRIMARY KEY,
    region_name      VARCHAR(255) NOT NULL,
    country_id       INT          NOT NULL,
    ta_insert_dt     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system    VARCHAR(255) NOT NULL,
    source_entity    VARCHAR(255) NOT NULL,
    source_region_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_regions_country
        FOREIGN KEY (country_id) REFERENCES bl_3nf.lkp_countries (country_id)
);

CREATE TABLE bl_3nf.lkp_cities (
    city_id        INT          PRIMARY KEY,
    city_name      VARCHAR(255) NOT NULL,
    region_id      INT          NOT NULL,
    ta_insert_dt   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system  VARCHAR(255) NOT NULL,
    source_entity  VARCHAR(255) NOT NULL,
    source_city_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_cities_region
        FOREIGN KEY (region_id) REFERENCES bl_3nf.lkp_regions (region_id)
);

CREATE TABLE bl_3nf.lkp_addresses (
    address_id        INT          PRIMARY KEY,
    street            VARCHAR(255) NOT NULL,
    house_number      VARCHAR(50)  NOT NULL,
    apartment_number  VARCHAR(50)  NOT NULL,
    postal_code       VARCHAR(50)  NOT NULL,
    city_id           INT          NOT NULL,
    ta_insert_dt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system     VARCHAR(255) NOT NULL,
    source_entity     VARCHAR(255) NOT NULL,
    source_address_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_addresses_city
        FOREIGN KEY (city_id) REFERENCES bl_3nf.lkp_cities (city_id)
);




CREATE TABLE bl_3nf.ce_product_categories (
    category_id        INT          PRIMARY KEY,
    category_name      VARCHAR(255) NOT NULL,
    ta_insert_dt       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system      VARCHAR(255) NOT NULL,
    source_entity      VARCHAR(255) NOT NULL,
    source_category_id VARCHAR(255) NOT NULL
);

CREATE TABLE bl_3nf.ce_product_brands (
    brand_id        INT          PRIMARY KEY,
    brand_name      VARCHAR(255) NOT NULL,
    ta_insert_dt    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system   VARCHAR(255) NOT NULL,
    source_entity   VARCHAR(255) NOT NULL,
    source_brand_id VARCHAR(255) NOT NULL
);


CREATE TABLE bl_3nf.ce_products_scd (
    product_id                   INT            NOT NULL,
    ta_start_dt                  TIMESTAMP      NOT NULL,
    source_product_id            VARCHAR(255)   NOT NULL,
    product_name                 VARCHAR(255)   NOT NULL,
    category_id                  INT            NOT NULL,
    brand_id                     INT            NOT NULL,
    product_description          VARCHAR(1000)  NOT NULL,
    product_price                DECIMAL(12,2)  NOT NULL,
    product_country_of_origin_id INT            NOT NULL,
    product_margin_rate          DECIMAL(5,2)   NOT NULL,
    ta_end_dt                    TIMESTAMP      NOT NULL DEFAULT TIMESTAMP '9999-12-31 00:00:00',
    is_active                    BOOLEAN        NOT NULL,
    ta_insert_dt                 TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system                VARCHAR(255)   NOT NULL,
    source_entity                VARCHAR(255)   NOT NULL,
    PRIMARY KEY (product_id, ta_start_dt),
    CONSTRAINT uq_products_version
        UNIQUE (source_system, source_entity, source_product_id, ta_start_dt),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)    REFERENCES bl_3nf.ce_product_categories (category_id),
    CONSTRAINT fk_products_brand
        FOREIGN KEY (brand_id)       REFERENCES bl_3nf.ce_product_brands (brand_id),
    CONSTRAINT fk_products_country
        FOREIGN KEY (product_country_of_origin_id) REFERENCES bl_3nf.lkp_countries (country_id)
);




CREATE TABLE bl_3nf.ce_warehouses (
    warehouse_id        INT          PRIMARY KEY,
    address_id          INT          NOT NULL,
    warehouse_type_id   INT          NOT NULL,
    capacity_units      INT          NOT NULL,
    num_employees       INT          NOT NULL,
    ta_insert_dt        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system       VARCHAR(255) NOT NULL,
    source_entity       VARCHAR(255) NOT NULL,
    source_warehouse_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_warehouses_address
        FOREIGN KEY (address_id)        REFERENCES bl_3nf.lkp_addresses (address_id),
    CONSTRAINT fk_warehouses_type
        FOREIGN KEY (warehouse_type_id) REFERENCES bl_3nf.lkp_warehouse_types (warehouse_type_id)
);

CREATE TABLE bl_3nf.ce_stores (
    store_id        INT          PRIMARY KEY,
    store_name      VARCHAR(255) NOT NULL,
    store_format_id INT          NOT NULL,
    address_id      INT          NOT NULL,
    ta_insert_dt    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system   VARCHAR(255) NOT NULL,
    source_entity   VARCHAR(255) NOT NULL,
    source_store_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_stores_format
        FOREIGN KEY (store_format_id) REFERENCES bl_3nf.lkp_store_formats (store_format_id),
    CONSTRAINT fk_stores_address
        FOREIGN KEY (address_id)      REFERENCES bl_3nf.lkp_addresses (address_id)
);




CREATE TABLE bl_3nf.ce_customers (
    customer_id                      INT          PRIMARY KEY,
    first_name                       VARCHAR(255) NOT NULL,
    last_name                        VARCHAR(255) NOT NULL,
    email                            VARCHAR(255) NOT NULL,
    phone                            VARCHAR(50)  NOT NULL,
    registration_dt                  TIMESTAMP    NOT NULL,
    address_id                       INT          NOT NULL,
    preferred_communication_channel_id INT        NOT NULL,
    loyalty_card_number              VARCHAR(255) NOT NULL,
    ta_insert_dt                     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt                     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system                    VARCHAR(255) NOT NULL,
    source_entity                    VARCHAR(255) NOT NULL,
    source_customer_id               VARCHAR(255) NOT NULL,
    CONSTRAINT fk_customers_address
        FOREIGN KEY (address_id)
            REFERENCES bl_3nf.lkp_addresses (address_id),
    CONSTRAINT fk_customers_channel
        FOREIGN KEY (preferred_communication_channel_id)
            REFERENCES bl_3nf.lkp_communication_channels (communication_channel_id)
);

CREATE TABLE bl_3nf.ce_cashiers (
    cashier_id        INT          PRIMARY KEY,
    first_name        VARCHAR(255) NOT NULL,
    last_name         VARCHAR(255) NOT NULL,
    email             VARCHAR(255) NOT NULL,
    phone             VARCHAR(50)  NOT NULL,
    employment_dt     TIMESTAMP    NOT NULL,
    role_id           INT          NOT NULL,
    shift_id          INT          NOT NULL,
    address_id        INT          NOT NULL,
    ta_insert_dt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system     VARCHAR(255) NOT NULL,
    source_entity     VARCHAR(255) NOT NULL,
    source_cashier_id VARCHAR(255) NOT NULL,
    CONSTRAINT fk_cashiers_role
        FOREIGN KEY (role_id)    REFERENCES bl_3nf.lkp_roles (role_id),
    CONSTRAINT fk_cashiers_shift
        FOREIGN KEY (shift_id)   REFERENCES bl_3nf.lkp_shifts (shift_id),
    CONSTRAINT fk_cashiers_address
        FOREIGN KEY (address_id) REFERENCES bl_3nf.lkp_addresses (address_id)
);



CREATE TABLE bl_3nf.ce_orders (
    order_id         INT          PRIMARY KEY,
    source_order_id  VARCHAR(255) NOT NULL,
    customer_id      INT          NOT NULL,
    channel_id       INT          NOT NULL,   
    order_status_id  INT          NOT NULL,
    order_dt         TIMESTAMP    NOT NULL,
    ta_insert_dt     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system    VARCHAR(255) NOT NULL,
    source_entity    VARCHAR(255) NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)     REFERENCES bl_3nf.ce_customers (customer_id),
    CONSTRAINT fk_orders_channel
        FOREIGN KEY (channel_id)      REFERENCES bl_3nf.lkp_channels (channel_id),
    CONSTRAINT fk_orders_status
        FOREIGN KEY (order_status_id) REFERENCES bl_3nf.lkp_order_statuses (order_status_id)
);


CREATE TABLE bl_3nf.ce_orders_offline (
    order_id   INT NOT NULL,
    store_id   INT NOT NULL,
    cashier_id INT NOT NULL,
    CONSTRAINT pk_orders_offline
        PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_offline_order
        FOREIGN KEY (order_id)   REFERENCES bl_3nf.ce_orders (order_id),
    CONSTRAINT fk_orders_offline_store
        FOREIGN KEY (store_id)   REFERENCES bl_3nf.ce_stores (store_id),
    CONSTRAINT fk_orders_offline_cashier
        FOREIGN KEY (cashier_id) REFERENCES bl_3nf.ce_cashiers (cashier_id)
);

CREATE TABLE bl_3nf.ce_order_items (
    order_id            INT            NOT NULL,
    product_id          INT            NOT NULL,
    quantity            INT            NOT NULL,
    order_item_amount   DECIMAL(12,2)  NOT NULL,
    discount_amount     DECIMAL(12,2)  NOT NULL,
    ta_insert_dt        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system       VARCHAR(255)   NOT NULL,
    source_entity       VARCHAR(255)   NOT NULL,
    source_order_item_id VARCHAR(255)  NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES bl_3nf.ce_orders (order_id)
);




CREATE TABLE bl_3nf.ce_payments (
    payment_id           INT          PRIMARY KEY,
    source_payment_id    VARCHAR(255) NOT NULL,
    payment_method_id    INT          NOT NULL,
    payment_status_id    INT          NOT NULL,
    payment_currency_id  INT          NOT NULL,
    payment_processor_id INT          NOT NULL,
    order_id             INT          NOT NULL,
    payment_dt           TIMESTAMP    NOT NULL,
    ta_insert_dt         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system        VARCHAR(255) NOT NULL,
    source_entity        VARCHAR(255) NOT NULL,
    CONSTRAINT fk_payments_method
        FOREIGN KEY (payment_method_id)    REFERENCES bl_3nf.lkp_payment_methods (payment_method_id),
    CONSTRAINT fk_payments_status
        FOREIGN KEY (payment_status_id)    REFERENCES bl_3nf.lkp_payment_statuses (payment_status_id),
    CONSTRAINT fk_payments_currency
        FOREIGN KEY (payment_currency_id)  REFERENCES bl_3nf.lkp_payment_currencies (payment_currency_id),
    CONSTRAINT fk_payments_processor
        FOREIGN KEY (payment_processor_id) REFERENCES bl_3nf.lkp_payment_processors (payment_processor_id),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)             REFERENCES bl_3nf.ce_orders (order_id)
);




CREATE TABLE bl_3nf.ce_deliveries (
    delivery_id          INT            PRIMARY KEY,
    order_id             INT            NOT NULL,
    delivery_status_id   INT            NOT NULL,
    delivery_type_id     INT            NOT NULL,
    shipping_fee         DECIMAL(12,2)  NOT NULL,
    delivery_dt          TIMESTAMP      NOT NULL,
    courier_company_id   INT            NOT NULL,
    courier_id           INT            NOT NULL,
    delivery_address_id  INT            NOT NULL,
    warehouse_id         INT            NOT NULL,
    ta_insert_dt         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ta_update_dt         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_system        VARCHAR(255)   NOT NULL,
    source_entity        VARCHAR(255)   NOT NULL,
    source_delivery_id   VARCHAR(255)   NOT NULL,
    CONSTRAINT fk_deliveries_order
        FOREIGN KEY (order_id)            REFERENCES bl_3nf.ce_orders (order_id),
    CONSTRAINT fk_deliveries_status
        FOREIGN KEY (delivery_status_id)  REFERENCES bl_3nf.lkp_delivery_statuses (delivery_status_id),
    CONSTRAINT fk_deliveries_type
        FOREIGN KEY (delivery_type_id)    REFERENCES bl_3nf.lkp_delivery_types (delivery_type_id),
    CONSTRAINT fk_deliveries_company
        FOREIGN KEY (courier_company_id)  REFERENCES bl_3nf.lkp_courier_companies (courier_company_id),
    CONSTRAINT fk_deliveries_address
        FOREIGN KEY (delivery_address_id) REFERENCES bl_3nf.lkp_addresses (address_id),
    CONSTRAINT fk_deliveries_warehouse
        FOREIGN KEY (warehouse_id)        REFERENCES bl_3nf.ce_warehouses (warehouse_id)
);



DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bl_cl_role') THEN
        CREATE ROLE bl_cl_role;
    END IF;
END $$;

GRANT bl_cl_role TO CURRENT_USER;

GRANT USAGE                  ON SCHEMA bl_3nf               TO bl_cl_role;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_3nf  TO bl_cl_role;
GRANT USAGE                  ON ALL SEQUENCES IN SCHEMA bl_3nf TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_3nf
    GRANT SELECT, INSERT, UPDATE ON TABLES    TO bl_cl_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_3nf
    GRANT USAGE                  ON SEQUENCES TO bl_cl_role;


------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS bl_dm;


CREATE TABLE IF NOT EXISTS bl_dm.dim_deliveries (
  delivery_id                BIGINT PRIMARY KEY DEFAULT -1,
  delivery_status_id         BIGINT      NOT NULL DEFAULT -1,
  delivery_status_name       VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  delivery_type_id           BIGINT      NOT NULL DEFAULT -1,
  delivery_type_name         VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  delivery_dt                DATE        NOT NULL DEFAULT DATE '1900-01-01',
  courier_company_id         BIGINT      NOT NULL DEFAULT -1,
  courier_company_name       VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  delivery_address_id        BIGINT      NOT NULL DEFAULT -1,
  courier_id                 BIGINT      NOT NULL DEFAULT -1,
  street                     VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  house_number               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  apartment_number           VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  postal_code                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  city_id                    BIGINT      NOT NULL DEFAULT -1,
  city_name                  VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  region_id                  BIGINT      NOT NULL DEFAULT -1,
  region_name                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_id                 BIGINT      NOT NULL DEFAULT -1,
  country_code               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_name               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  ta_insert_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  ta_update_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_delivery_id         VARCHAR     NOT NULL DEFAULT 'UNKNOWN'
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_warehouses (
  warehouse_id               BIGINT PRIMARY KEY DEFAULT -1,
  warehouse_type_id          BIGINT      NOT NULL DEFAULT -1,
  warehouse_type_name        VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  num_employees              BIGINT      NOT NULL DEFAULT -1,
  capacity_units             BIGINT      NOT NULL DEFAULT -1,
  address_id                 BIGINT      NOT NULL DEFAULT -1,
  street                     VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  house_number               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  apartment_number           VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  postal_code                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  city_id                    BIGINT      NOT NULL DEFAULT -1,
  city_name                  VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  region_id                  BIGINT      NOT NULL DEFAULT -1,
  region_name                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_id                 BIGINT      NOT NULL DEFAULT -1,
  country_code               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_name               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  ta_insert_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  ta_update_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_warehouse_id        VARCHAR     NOT NULL DEFAULT 'UNKNOWN'
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_cashiers (
  cashier_id                 BIGINT PRIMARY KEY DEFAULT -1,
  first_name                 VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  last_name                  VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  email                      VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  phone                      VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  employment_dt              DATE        NOT NULL DEFAULT DATE '1900-01-01',
  role_id                    BIGINT      NOT NULL DEFAULT -1,
  role_name                  VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  shift_id                   BIGINT      NOT NULL DEFAULT -1,
  shift_name                 VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  cashier_address_id         BIGINT      NOT NULL DEFAULT -1,
  street                     VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  house_number               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  apartment_number           VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  postal_code                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  city_id                    BIGINT      NOT NULL DEFAULT -1,
  city_name                  VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  region_id                  BIGINT      NOT NULL DEFAULT -1,
  region_name                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_id                 BIGINT      NOT NULL DEFAULT -1,
  country_code               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_name               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  ta_insert_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  ta_update_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_customer_id         VARCHAR     NOT NULL DEFAULT 'UNKNOWN'
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_customers (
  customer_id                           BIGINT PRIMARY KEY DEFAULT -1,
  first_name                            VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  last_name                             VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  email                                 VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  phone                                 VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  registration_dt                        DATE        NOT NULL DEFAULT DATE '1900-01-01',
  preferred_communication_channel_id      BIGINT      NOT NULL DEFAULT -1,
  preferred_communication_channel_name    VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  loyalty_card_number                    VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  customer_address_id                    BIGINT      NOT NULL DEFAULT -1,
  street                                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  house_number                          VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  apartment_number                      VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  postal_code                           VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  city_id                               BIGINT      NOT NULL DEFAULT -1,
  city_name                             VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  region_id                             BIGINT      NOT NULL DEFAULT -1,
  region_name                           VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_id                            BIGINT      NOT NULL DEFAULT -1,
  country_code                          VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_name                          VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  ta_insert_dt                           DATE        NOT NULL DEFAULT CURRENT_DATE,
  ta_update_dt                           DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system                          VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity                          VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_customer_id                     VARCHAR     NOT NULL DEFAULT 'UNKNOWN'
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_order_status (
  order_status_id            BIGINT PRIMARY KEY DEFAULT -1,
  order_status_name          VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  ta_insert_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_order_status_id     VARCHAR     NOT NULL DEFAULT 'UNKNOWN'
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_stores (
  store_id                   BIGINT PRIMARY KEY DEFAULT -1,
  store_name                 VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  store_format_id            BIGINT      NOT NULL DEFAULT -1,
  store_format_name          VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  store_address_id           BIGINT      NOT NULL DEFAULT -1,
  street                     VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  house_number               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  apartment_number           VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  postal_code                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  city_id                    BIGINT      NOT NULL DEFAULT -1,
  city_name                  VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  region_id                  BIGINT      NOT NULL DEFAULT -1,
  region_name                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_id                 BIGINT      NOT NULL DEFAULT -1,
  country_code               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_name               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  ta_insert_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  ta_update_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_store_id            VARCHAR     NOT NULL DEFAULT 'UNKNOWN'
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_payments (
  payment_id                 BIGINT PRIMARY KEY DEFAULT -1,
  payment_method_id          BIGINT      NOT NULL DEFAULT -1,
  payment_method_name        VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  payment_status_id          BIGINT      NOT NULL DEFAULT -1,
  payment_status_name        VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  payment_currency_id        BIGINT      NOT NULL DEFAULT -1,
  payment_currency_name      VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  payment_processor_id       BIGINT      NOT NULL DEFAULT -1,
  payment_processor_name     VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  payment_dt                 DATE        NOT NULL DEFAULT DATE '1900-01-01',
  ta_insert_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  ta_update_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_payment_id          VARCHAR     NOT NULL DEFAULT 'UNKNOWN'
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_dates (
  date_id                    BIGINT PRIMARY KEY DEFAULT -1,
  full_date                  DATE        NOT NULL DEFAULT DATE '1900-01-01',
  day_of_week                VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  day_name                   VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  week_of_year               BIGINT      NOT NULL DEFAULT -1,
  month                      BIGINT      NOT NULL DEFAULT -1,
  month_name                 VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  quarter                    BIGINT      NOT NULL DEFAULT -1,
  year                       BIGINT      NOT NULL DEFAULT -1,
  is_weekend                 BOOLEAN     NOT NULL DEFAULT FALSE,
  is_holiday                 BOOLEAN     NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS bl_dm.dim_products_scd (
  product_id                 BIGINT PRIMARY KEY DEFAULT -1,
  product_name               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  category_id                BIGINT      NOT NULL DEFAULT -1,
  category_name              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  brand_id                   BIGINT      NOT NULL DEFAULT -1,
  brand_name                 VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  product_description        VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  product_price              DECIMAL     NOT NULL DEFAULT 0,
  product_country_of_origin_id BIGINT    NOT NULL DEFAULT -1,
  country_code               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  country_name               VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  product_margin_rate        DECIMAL     NOT NULL DEFAULT 0,
  ta_start_dt                DATE        NOT NULL DEFAULT CURRENT_DATE,
  ta_end_dt                  DATE        NOT NULL DEFAULT DATE '9999-12-31',
  is_active                  BOOLEAN     NOT NULL DEFAULT FALSE,
  ta_insert_dt               DATE        NOT NULL DEFAULT CURRENT_DATE,
  source_system              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_entity              VARCHAR     NOT NULL DEFAULT 'UNKNOWN',
  source_product_id          VARCHAR     NOT NULL DEFAULT -1
);






------------------------
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
-----------------------


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
    CALL bl_cl.load_fact_rolling_window();


    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'INFO',
        'BL_DM load completed in '
        || EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start))::INT || 's');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.log_load(v_proc, 'ALL', 'BL_3NF', 0, 'ERROR',
        'BL_DM load FAILED: ' || SQLERRM);
    RAISE;
END;
$$;

