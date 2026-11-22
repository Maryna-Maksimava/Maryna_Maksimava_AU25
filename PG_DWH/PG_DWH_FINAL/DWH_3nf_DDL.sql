


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