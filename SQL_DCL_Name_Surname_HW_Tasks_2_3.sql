--2

CREATE USER rentaluser WITH PASSWORD 'rentalpassword';

GRANT CONNECT ON DATABASE dvdrental TO rentaluser;

GRANT SELECT ON customer TO rentaluser;



SET ROLE rentaluser;
--test role
SELECT * FROM customer LIMIT 5;
--get back to postgres to create roles
SET ROLE postgres
	
CREATE ROLE rental;
GRANT rental TO rentaluser;
GRANT INSERT, UPDATE ON rental TO rental;
--Test INSERT/UPDATE:
INSERT INTO rental(rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 1, 1);
UPDATE rental SET staff_id=2 WHERE rental_id=1;

REVOKE INSERT ON rental FROM rental;
-- test INSERT and it fails
SET ROLE rental;
INSERT INTO rental(rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 1, 1);	

CREATE ROLE client_Elizabeth_Brown;

--3
ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON rental TO client_Elizabeth_Brown;
GRANT SELECT ON payment TO client_Elizabeth_Brown;


-- Create policies
CREATE POLICY rental_policy ON rental
    FOR SELECT
    TO client_Elizabeth_Brown
    USING (customer_id = 5);

CREATE POLICY payment_policy ON payment
    FOR SELECT
    TO client_Elizabeth_Brown
    USING (customer_id = 5);

-- Test
SET ROLE client_Elizabeth_Brown;
SELECT * FROM rental;
SELECT * FROM payment;
