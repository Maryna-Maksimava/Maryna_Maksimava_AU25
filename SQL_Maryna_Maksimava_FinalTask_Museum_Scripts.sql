-------------------
--CREATION SCRIPT
---------------------
-- Drop schema if exists
DROP SCHEMA IF EXISTS museum CASCADE;

-- create schema
CREATE SCHEMA museum;
SET search_path TO museum;

--create location type table
DROP TABLE IF EXISTS museum.LocationType CASCADE;

CREATE TABLE museum.LocationType (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL UNIQUE
);

--create location table
DROP TABLE IF EXISTS museum.Location CASCADE;

CREATE TABLE museum.Location (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(200) NOT NULL,
    address VARCHAR(300) NOT NULL UNIQUE,
    locationTypeId BIGINT NOT NULL,

    CONSTRAINT fk_location_locationtype
        FOREIGN KEY (locationTypeId)
        REFERENCES museum.LocationType(id)
);

--create item type table
DROP TABLE IF EXISTS museum.ItemType CASCADE;

CREATE TABLE museum.ItemType (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL
);

--create visitor table
DROP TABLE IF EXISTS museum.Visitor CASCADE;

CREATE TABLE museum.Visitor (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    phone VARCHAR(30) UNIQUE
);

--create employee table
DROP TABLE IF EXISTS museum.Employee CASCADE;

CREATE TABLE museum.Employee (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    phone VARCHAR(30) UNIQUE,
    email VARCHAR(200) UNIQUE,
    locationId BIGINT NOT NULL,
    hireDate DATE NOT NULL,

    CONSTRAINT fk_employee_location
        FOREIGN KEY (locationId)
        REFERENCES museum.Location(id)
);

--create exhibition table
DROP TABLE IF EXISTS museum.Exhibition CASCADE;

CREATE TABLE museum.Exhibition (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    startDate DATE NOT NULL,
    endDate DATE,
    locationId BIGINT NOT NULL,

    CONSTRAINT fk_exhibition_location
        FOREIGN KEY (locationId)
        REFERENCES museum.Location(id)
);

--create museum item table
DROP TABLE IF EXISTS museum.MuseumItem CASCADE;

CREATE TABLE museum.MuseumItem (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    itemTypeId BIGINT NOT NULL,
    period VARCHAR(150),
    currentLocationId BIGINT NOT NULL,

    CONSTRAINT fk_museumitem_itemtype
        FOREIGN KEY (itemTypeId)
        REFERENCES museum.ItemType(id),

    CONSTRAINT fk_museumitem_location
        FOREIGN KEY (currentLocationId)
        REFERENCES museum.Location(id)
);

--create visit table
DROP TABLE IF EXISTS museum.Visit CASCADE;

CREATE TABLE museum.Visit (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    exhibitionId BIGINT NOT NULL,
    visitorId BIGINT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_visit_exhibition
        FOREIGN KEY (exhibitionId)
        REFERENCES museum.Exhibition(id),

    CONSTRAINT fk_visit_visitor
        FOREIGN KEY (visitorId)
        REFERENCES museum.Visitor(id)
);

--create exhibition item table
DROP TABLE IF EXISTS museum.ExhibitionItem CASCADE;

CREATE TABLE museum.ExhibitionItem (
    exhibitionId BIGINT NOT NULL,
    itemId BIGINT NOT NULL,
    spotNumber INT NOT NULL,

    CONSTRAINT pk_exhibitionitem
        PRIMARY KEY (exhibitionId, itemId),

    CONSTRAINT fk_exhibitionitem_exhibition
        FOREIGN KEY (exhibitionId)
        REFERENCES museum.Exhibition(id),

    CONSTRAINT fk_exhibitionitem_item
        FOREIGN KEY (itemId)
        REFERENCES museum.MuseumItem(id)
);

--add constraints using ALTER
ALTER TABLE museum.Exhibition
ADD CONSTRAINT chk_exhibition_startdate
CHECK (startDate >= DATE '2020-01-01');

ALTER TABLE museum.Exhibition
ADD CONSTRAINT chk_exhibition_enddate
CHECK (endDate IS NULL OR endDate >= startDate);

ALTER TABLE museum.Employee
ADD CONSTRAINT chk_employee_hiredate
CHECK (hireDate >= DATE '2020-01-01');

ALTER TABLE museum.Visit
ADD CONSTRAINT chk_visit_date_not_future
CHECK (date <= CURRENT_DATE);

ALTER TABLE museum.ExhibitionItem
ADD CONSTRAINT chk_spot_positive
CHECK (spotNumber > 0);
-------------------
--INSERTION SCRIPT
---------------------
---------------
INSERT INTO museum.LocationType (name) VALUES
    ('Gallery'),
    ('Storage'),
    ('Restoration Lab'),
    ('Office'),
    ('Outdoor'),
    ('Digital');
--------------
INSERT INTO museum.Location (name, address, locationTypeId) VALUES
 ('Main Gallery',   '100 Art St',      (SELECT id FROM museum.LocationType WHERE name='Gallery')),
 ('East Storage',   '200 Storage Rd',  (SELECT id FROM museum.LocationType WHERE name='Storage')),
 ('Restoration A',  '300 Lab Ave',     (SELECT id FROM museum.LocationType WHERE name='Restoration Lab')),
 ('Admin Office',   '400 Office Ln',   (SELECT id FROM museum.LocationType WHERE name='Office')),
 ('Sculpture Yard', '500 Outdoor Pl',  (SELECT id FROM museum.LocationType WHERE name='Outdoor')),
 ('Digital Wing',   '600 Virtual Ct',  (SELECT id FROM museum.LocationType WHERE name='Digital'));
---------------
INSERT INTO museum.ItemType (name, description) VALUES
 ('Painting', 'Artwork on canvas'),
 ('Sculpture', '3D art piece'),
 ('Weapon', 'Historical weapon'),
 ('Jewelry', 'Historical decorative piece'),
 ('Document', 'Historical written record'),
 ('Textile', 'Fabric artifacts');
-----------------
INSERT INTO museum.Visitor (firstName, lastName, phone) VALUES
 ('Anna',  'Smith',  '1001'),
 ('John',  'Miller', '1002'),
 ('Maria', 'Rivera', '1003'),
 ('Peter', 'Wong',   '1004'),
 ('Sarah', 'Lee',    '1005'),
 ('David', 'Khan',   '1006');
---------------
INSERT INTO museum.Employee (firstName, lastName, phone, email, locationId, hireDate) VALUES
 ('Emily', 'Stone', '2001', 'emily@museum.com',
    (SELECT id FROM museum.Location WHERE name='Main Gallery'),
    DATE '2021-05-01'),

 ('Mark', 'Hill', '2002', 'mark@museum.com',
    (SELECT id FROM museum.Location WHERE name='East Storage'),
    DATE '2022-03-10'),

 ('Olga', 'Ivanova', '2003', 'olga@museum.com',
    (SELECT id FROM museum.Location WHERE name='Restoration A'),
    DATE '2023-02-15'),

 ('Victor', 'Chen', '2004', 'victor@museum.com',
    (SELECT id FROM museum.Location WHERE name='Admin Office'),
    DATE '2020-12-01'),

 ('Laura', 'King', '2005', 'laura@museum.com',
    (SELECT id FROM museum.Location WHERE name='Sculpture Yard'),
    DATE '2021-09-20'),

 ('Sven', 'Berg', '2006', 'sven@museum.com',
    (SELECT id FROM museum.Location WHERE name='Digital Wing'),
    DATE '2023-07-12');
-----------------------
INSERT INTO museum.Exhibition (name, description, startDate, endDate, locationId) VALUES
 ('Winter Wonders', 'Seasonal exhibition',
    CURRENT_DATE - INTERVAL '60 days',
    CURRENT_DATE - INTERVAL '30 days',
    (SELECT id FROM museum.Location WHERE name='Main Gallery')),

 ('Historic Arms', 'Collection of ancient weapons',
    CURRENT_DATE - INTERVAL '50 days',
    CURRENT_DATE - INTERVAL '20 days',
    (SELECT id FROM museum.Location WHERE name='East Storage')),

 ('Golden Jewels', 'Jewelry through time',
    CURRENT_DATE - INTERVAL '45 days',
    CURRENT_DATE - INTERVAL '10 days',
    (SELECT id FROM museum.Location WHERE name='Admin Office')),

 ('Digital Dreams', 'Virtual art exhibition',
    CURRENT_DATE - INTERVAL '40 days',
    CURRENT_DATE - INTERVAL '5 days',
    (SELECT id FROM museum.Location WHERE name='Digital Wing')),

 ('Sculpture Stories', 'Outdoor sculpture show',
    CURRENT_DATE - INTERVAL '30 days',
    CURRENT_DATE,
    (SELECT id FROM museum.Location WHERE name='Sculpture Yard')),

 ('Textile Traditions', 'Historic fabrics',
    CURRENT_DATE - INTERVAL '20 days',
    CURRENT_DATE - INTERVAL '1 days',
    (SELECT id FROM museum.Location WHERE name='Restoration A'));

----------------
INSERT INTO museum.MuseumItem (name, description, itemTypeId, period, currentLocationId) VALUES
 ('Sunset Painting', 'Oil on canvas',
    (SELECT id FROM museum.ItemType WHERE name='Painting'),
    'Modern',
    (SELECT id FROM museum.Location WHERE name='Main Gallery')),

 ('Bronze Statue', 'Small bronze figure',
    (SELECT id FROM museum.ItemType WHERE name='Sculpture'),
    'Ancient',
    (SELECT id FROM museum.Location WHERE name='Sculpture Yard')),

 ('Samurai Sword', 'Traditional Japanese weapon',
    (SELECT id FROM museum.ItemType WHERE name='Weapon'),
    'Medieval',
    (SELECT id FROM museum.Location WHERE name='East Storage')),

 ('Golden Necklace', '18th century necklace',
    (SELECT id FROM museum.ItemType WHERE name='Jewelry'),
    'Renaissance',
    (SELECT id FROM museum.Location WHERE name='Admin Office')),

 ('Royal Decree', 'Historic document',
    (SELECT id FROM museum.ItemType WHERE name='Document'),
    'Ancient',
    (SELECT id FROM museum.Location WHERE name='Digital Wing')),

 ('Silk Banner', 'Historic textile banner',
    (SELECT id FROM museum.ItemType WHERE name='Textile'),
    'Contemporary',
    (SELECT id FROM museum.Location WHERE name='Restoration A'));


------------------------
INSERT INTO museum.Visit (exhibitionId, visitorId, date) VALUES
  (
    (SELECT id FROM museum.Exhibition WHERE name = 'Winter Wonders'),
    (SELECT id FROM museum.Visitor    WHERE firstName = 'Anna'),
    CURRENT_DATE - INTERVAL '14 days'
  ),
  (
    (SELECT id FROM museum.Exhibition WHERE name = 'Historic Arms'),
    (SELECT id FROM museum.Visitor    WHERE firstName = 'John'),
    CURRENT_DATE - INTERVAL '10 days'
  ),
  (
    (SELECT id FROM museum.Exhibition WHERE name = 'Golden Jewels'),
    (SELECT id FROM museum.Visitor    WHERE firstName = 'Maria'),
    CURRENT_DATE - INTERVAL '20 days'
  ),
  (
    (SELECT id FROM museum.Exhibition WHERE name = 'Digital Dreams'),
    (SELECT id FROM museum.Visitor    WHERE firstName = 'Peter'),
    CURRENT_DATE - INTERVAL '5 days'
  ),
  (
    (SELECT id FROM museum.Exhibition WHERE name = 'Textile Traditions'),
    (SELECT id FROM museum.Visitor    WHERE firstName = 'Sarah'),
    CURRENT_DATE - INTERVAL '8 days'
  ),
  (
    (SELECT id FROM museum.Exhibition WHERE name = 'Sculpture Stories'),
    (SELECT id FROM museum.Visitor    WHERE firstName = 'David'),
    CURRENT_DATE - INTERVAL '2 days'
  );


------------------------------------------

INSERT INTO museum.ExhibitionItem (exhibitionId, itemId, spotNumber) VALUES
 ((SELECT id FROM museum.Exhibition WHERE name='Winter Wonders'),
  (SELECT id FROM museum.MuseumItem WHERE name='Sunset Painting'),
  1),

 ((SELECT id FROM museum.Exhibition WHERE name='Historic Arms'),
  (SELECT id FROM museum.MuseumItem WHERE name='Samurai Sword'),
  2),

 ((SELECT id FROM museum.Exhibition WHERE name='Golden Jewels'),
  (SELECT id FROM museum.MuseumItem WHERE name='Golden Necklace'),
  3),

 ((SELECT id FROM museum.Exhibition WHERE name='Digital Dreams'),
  (SELECT id FROM museum.MuseumItem WHERE name='Royal Decree'),
  4),

 ((SELECT id FROM museum.Exhibition WHERE name='Sculpture Stories'),
  (SELECT id FROM museum.MuseumItem WHERE name='Bronze Statue'),
  5),

 ((SELECT id FROM museum.Exhibition WHERE name='Textile Traditions'),
  (SELECT id FROM museum.MuseumItem WHERE name='Silk Banner'),
  6);

-------------------
--CREATE FUNCTIONS AND VIEWS
---------------------
CREATE OR REPLACE FUNCTION museum.update_museum_item_column(
    p_id BIGINT,
    p_column TEXT,
    p_new_value TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    sql_text TEXT;
BEGIN
    -- Validate column name (only allow safe columns)
    IF p_column NOT IN ('name', 'description', 'period') THEN
        RAISE EXCEPTION 'Invalid or restricted column name: %', p_column;
    END IF;

    -- Build dynamic SQL
    sql_text := format(
        'UPDATE museum.MuseumItem SET %I = $1 WHERE id = $2',
        p_column
    );

    -- Execute update
    EXECUTE sql_text USING p_new_value, p_id;

    RAISE NOTICE 'MuseumItem row % updated: set % to %', p_id, p_column, p_new_value;
END;
$$;

----------------------------
CREATE OR REPLACE FUNCTION museum.add_visit_transaction(
    p_visitor_first TEXT,
    p_visitor_last  TEXT,
    p_exhibition_name TEXT,
    p_visit_date DATE DEFAULT CURRENT_DATE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_visitor_id BIGINT;
    v_exhibition_id BIGINT;
BEGIN
    -- Get visitor id via natural key
    SELECT id INTO v_visitor_id
    FROM museum.Visitor
    WHERE firstName = p_visitor_first
      AND lastName = p_visitor_last;

    IF v_visitor_id IS NULL THEN
        RAISE EXCEPTION 'Visitor not found: % %', p_visitor_first, p_visitor_last;
    END IF;

    -- Get exhibition id via natural key
    SELECT id INTO v_exhibition_id
    FROM museum.Exhibition
    WHERE name = p_exhibition_name;

    IF v_exhibition_id IS NULL THEN
        RAISE EXCEPTION 'Exhibition not found: %', p_exhibition_name;
    END IF;

    -- Insert visit (transaction)
    INSERT INTO museum.Visit (exhibitionId, visitorId, date)
    VALUES (v_exhibition_id, v_visitor_id, p_visit_date);

    -- Confirm success
    RAISE NOTICE 'Visit added: Visitor % %, Exhibition %, Date %',
         p_visitor_first, p_visitor_last, p_exhibition_name, p_visit_date;
END;
$$;

---------------------------------------
CREATE OR REPLACE VIEW museum.visit_analytics_last_quarter AS
SELECT
    e.name AS exhibition_name,
    e.startDate AS exhibition_start,
    e.endDate AS exhibition_end,
    COUNT(v.id) AS total_visits,
    COUNT(DISTINCT vi.id) AS distinct_visitors,
    MIN(vi.date) AS earliest_visit,
    MAX(vi.date) AS latest_visit
FROM museum.Exhibition e
JOIN museum.Visit vi 
    ON vi.exhibitionId = e.id
JOIN museum.Visitor v
    ON v.id = vi.visitorId
WHERE vi.date >= (CURRENT_DATE - INTERVAL '3 months')
GROUP BY
    e.name, e.startDate, e.endDate
ORDER BY total_visits DESC;
-----------------------------------
-- 1. Create the role with login capability
CREATE ROLE museum_manager
    LOGIN
    PASSWORD 'StrongPassword123!'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT;

GRANT USAGE ON SCHEMA museum TO museum_manager;

GRANT SELECT ON ALL TABLES IN SCHEMA museum TO museum_manager;

ALTER DEFAULT PRIVILEGES IN SCHEMA museum
GRANT SELECT ON TABLES TO museum_manager;
