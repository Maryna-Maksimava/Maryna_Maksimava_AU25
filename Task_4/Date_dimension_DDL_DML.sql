CREATE TABLE IF NOT EXISTS date_dimension (
    date_id INTEGER PRIMARY KEY, 
    full_date  DATE NOT NULL,

    day_of_week INTEGER  NOT NULL,       -- 1–7
    day_name VARCHAR(10)  NOT NULL,       -- Monday, Tuesday, ...
    week_of_year INTEGER NOT NULL,       -- 1–53

    month INTEGER NOT NULL,       -- 1–12
    month_name VARCHAR(10) NOT NULL,       -- January, February, ...
    quarter INTEGER NOT NULL,       -- 1–4
    year INTEGER NOT NULL,

    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN NOT NULL
);

INSERT INTO date_dimension (
    date_id,
    full_date,
    day_of_week,
    day_name,
    week_of_year,
    month,
    month_name,
    quarter,
    year,
    is_weekend,
    is_holiday
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_id,
    d AS full_date,

    EXTRACT(ISODOW FROM d)::INTEGER              AS day_of_week,
    TO_CHAR(d, 'FMDay')                          AS day_name,
    EXTRACT(WEEK FROM d)::INTEGER                AS week_of_year,

    EXTRACT(MONTH FROM d)::INTEGER               AS month,
    TO_CHAR(d, 'FMMonth')                        AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER             AS quarter,
    EXTRACT(YEAR FROM d)::INTEGER                AS year,

    CASE WHEN EXTRACT(ISODOW FROM d) IN (6, 7)
         THEN TRUE ELSE FALSE END                AS is_weekend,

    FALSE                                       AS is_holiday
FROM generate_series(
        DATE '2024-01-01',
        DATE '2026-01-31',
        INTERVAL '1 day'
     ) AS d
ON CONFLICT (date_id) DO NOTHING;

-- 1. Reset holidays in the target range
UPDATE date_dimension
SET is_holiday = FALSE
WHERE full_date BETWEEN DATE '2024-01-01' AND DATE '2026-01-31';


-- 2. Set Lithuanian public holidays
UPDATE date_dimension
SET is_holiday = TRUE
WHERE full_date IN (
    -- 2024
    DATE '2024-01-01', -- New Year's Day
    DATE '2024-02-16', -- Restoration of the State of Lithuania
    DATE '2024-03-11', -- Restoration of Independence
    DATE '2024-03-31', -- Easter Sunday
    DATE '2024-04-01', -- Easter Monday
    DATE '2024-05-01', -- Labour Day
    DATE '2024-05-05', -- Mother's Day
    DATE '2024-06-02', -- Father's Day
    DATE '2024-06-24', -- Joninės (Midsummer)
    DATE '2024-07-06', -- Statehood Day
    DATE '2024-08-15', -- Assumption
    DATE '2024-11-01', -- All Saints' Day
    DATE '2024-11-02', -- All Souls' Day
    DATE '2024-12-24', -- Christmas Eve
    DATE '2024-12-25', -- Christmas Day
    DATE '2024-12-26', -- Second Day of Christmas

    -- 2025
    DATE '2025-01-01',
    DATE '2025-02-16',
    DATE '2025-03-11',
    DATE '2025-04-20',
    DATE '2025-04-21',
    DATE '2025-05-01',
    DATE '2025-05-04',
    DATE '2025-06-01',
    DATE '2025-06-24',
    DATE '2025-07-06',
    DATE '2025-08-15',
    DATE '2025-11-01',
    DATE '2025-11-02',
    DATE '2025-12-24',
    DATE '2025-12-25',
    DATE '2025-12-26',

    -- 2026 (within range)
    DATE '2026-01-01'
);