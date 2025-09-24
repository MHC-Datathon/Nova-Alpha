SELECT * FROM enforcement_violations;

--Q1: What is The violation hotstop by station?
SELECT
    stop_name,
    bus_stop_latitude,
    bus_stop_longitude,
    COUNT(violation_ID) AS total_violations
FROM
    enforcement_violations
WHERE
    stop_name IS NOT NULL
    AND bus_stop_latitude IS NOT NULL
    AND bus_stop_longitude IS NOT NULL
GROUP BY
    stop_name, bus_stop_latitude, bus_stop_longitude
ORDER BY
    total_violations DESC;

-- Q2:Ro is working on this one
-- How does the distribution and type of violations (Bus Lane vs. Bus Stop vs. Double Parking) differ across the five boroughs? 
-- Task: Find borough name for each bus stop,
SELECT vehicle_ID, stop_name, bus_stop_georeference,  COUNT(violation_ID) AS no_of_violations, MAX(violation_type) AS most_common_violation
FROM enforcement_violations
GROUP BY stop_name
--HAVING COUNT(violation_ID) > 50
ORDER BY no_of_violations DESC;

--Q3
--- What is the rate of repeat offenders ? Violation issued vs other categories except for exempt. And categorize them by bus stops.
--- Categorize violations issued by bus stops. 
-- Observation: The violation percentages are the exact same by percentage category.
WITH ViolationsWithCategory AS (
    -- Step 1: Create two categories: 'Violation Issued' and 'Other Non-Exempt'
    SELECT
        vehicle_ID,
        CASE
            WHEN violation_status = 'VIOLATION ISSUED'
            THEN 'Violation Issued'
            ELSE 'Other Non-Exempt'
        END AS offense_category
    FROM
        enforcement_violations
    WHERE
        violation_status NOT LIKE 'EXEMPT%' -- Filter out all EXEMPT statuses
),
VehicleCountsByCategory AS (
    -- Step 2: Count the violations for each vehicle within its new category
    SELECT
        vehicle_ID,
        offense_category,
        COUNT(*) AS violation_count
    FROM
        ViolationsWithCategory
    GROUP BY
        vehicle_ID,
        offense_category
)
-- Step 3: Calculate the final rate for each category
SELECT
    offense_category,
    -- Numerator: Count of vehicles with more than 1 violation
    CAST(SUM(CASE WHEN violation_count > 1 THEN 1 ELSE 0 END) AS REAL) * 100 /
    -- Denominator: Total count of unique vehicles in the category
    COUNT(vehicle_ID) AS repeat_offender_rate_percent
FROM
    VehicleCountsByCategory
GROUP BY
    offense_category;


--- Categorize them by bus stops. violations issued.
SELECT
    stop_name,
    -- The calculation remains the same, but it runs on the filtered data
    CAST(COUNT(violation_ID) AS REAL) * 100 / SUM(COUNT(violation_ID)) OVER () AS percentage_of_issued_violations
FROM
    enforcement_violations
WHERE
    stop_name IS NOT NULL
    AND violation_status = 'VIOLATION ISSUED' 
GROUP BY
    stop_name
ORDER BY
    percentage_of_issued_violations ASC;
	

-- Q4:
-- What percentage of violators receive more than one ticket within a 12-month period?
WITH FormattedViolations AS (
    -- Step 1: Extract and reformat the date text for ISSUED violations only
    SELECT
        vehicle_ID,
        -- Build the 'YYYY-MM-DD' string
        SUBSTR(first_occurrence, 7, 4) || '-' || SUBSTR(first_occurrence, 1, 2) || '-' || SUBSTR(first_occurrence, 4, 2) AS violation_date
    FROM
        enforcement_violations
    WHERE
        LENGTH(first_occurrence) > 10
        AND violation_status = 'VIOLATION ISSUED' -- <-- Filter added here
),
RankedViolations AS (
    -- Step 2: Find the date of the previous ISSUED violation.
    SELECT
        vehicle_ID,
        violation_date,
        LAG(violation_date, 1) OVER (
            PARTITION BY vehicle_ID ORDER BY violation_date
        ) AS previous_violation_date
    FROM
        FormattedViolations
),
RepeatViolators AS (
    -- Step 3: Create a unique list of repeat violators based on ISSUED violations.
    SELECT DISTINCT
        vehicle_ID
    FROM
        RankedViolations
    WHERE
        JULIANDAY(violation_date) - JULIANDAY(previous_violation_date) <= 365
)
-- Step 4: Calculate the final percentage using only ISSUED violations.
SELECT
    CAST( (SELECT COUNT(*) FROM RepeatViolators) AS REAL) * 100 /
    (SELECT COUNT(DISTINCT vehicle_ID) FROM enforcement_violations WHERE violation_status = 'VIOLATION ISSUED') AS percentage_repeat_in_12_months; -- <-- Filter also added here
	
--Q5: 
--Is there a strong correlation between specific bus routes and the dominant type of violation they experience? 
WITH RankedViolations AS (
    -- Step 1: Count each violation type per route and rank them by frequency
    SELECT
        bus_route_ID,
        violation_type,
        COUNT(violation_ID) AS violation_count,
        ROW_NUMBER() OVER(
            PARTITION BY bus_route_ID 
            ORDER BY COUNT(violation_ID) DESC
        ) AS rn
    FROM
        enforcement_violations
    WHERE
        bus_route_ID IS NOT NULL 
        AND violation_status = 'VIOLATION ISSUED'
    GROUP BY
        bus_route_ID,
        violation_type
)
-- Step 2: Select only the top-ranked violation (#1) for each route
SELECT
    bus_route_ID,
    violation_type AS dominant_violation_type,
    violation_count
FROM
    RankedViolations
WHERE
    rn = 1
ORDER BY
    bus_route_ID;
	
--Q6: Ro is working on this one
--If there is a correlation between ticket counts and low income areas.

--Q7: What are the peak hours for violations?
WITH ViolationTimes AS (
  SELECT
    -- Determine if the violation occurred on a weekday or weekend
    CASE 
      WHEN STRFTIME('%w', SUBSTR(first_occurrence, 7, 4) || '-' || SUBSTR(first_occurrence, 1, 2) || '-' || SUBSTR(first_occurrence, 4, 2)) IN ('0', '6')
      THEN 'Weekend'
      ELSE 'Weekday'
    END AS day_type,
    SUBSTR(first_occurrence, 12, 2) AS hour_12,
    SUBSTR(first_occurrence, 21, 2) AS am_pm
  FROM 
    enforcement_violations
  WHERE 
    violation_status = 'VIOLATION ISSUED'
)
SELECT
  day_type,
  -- Convert 12-hour time to a 24-hour format for proper sorting and display
  CASE
    WHEN am_pm = 'PM' AND hour_12 != '12' THEN CAST(hour_12 AS INTEGER) + 12
    WHEN am_pm = 'AM' AND hour_12 = '12' THEN 0 -- Handle midnight case
    ELSE CAST(hour_12 AS INTEGER)
  END AS hour_of_day,
  COUNT(*) as violation_count
FROM 
  ViolationTimes
GROUP BY 
  day_type, hour_of_day
ORDER BY 
  day_type, hour_of_day;
  
  
 -- Q8: How quickly do repeat offenders get another ticket?
WITH FormattedViolations AS (
    SELECT
        vehicle_ID,
        violation_type,
        -- Convert date text to a standard YYYY-MM-DD format
        SUBSTR(first_occurrence, 7, 4) || '-' || SUBSTR(first_occurrence, 1, 2) || '-' || SUBSTR(first_occurrence, 4, 2) AS violation_date
    FROM 
      enforcement_violations
    WHERE 
      violation_status = 'VIOLATION ISSUED' AND LENGTH(first_occurrence) > 10
),
ViolationGaps AS (
    SELECT
        violation_type, -- The type of the current violation
        -- Calculate the days since the vehicle's last violation of any type
        JULIANDAY(violation_date) - JULIANDAY(
            LAG(violation_date, 1) OVER (PARTITION BY vehicle_ID ORDER BY violation_date)
        ) AS days_since_last_violation
    FROM FormattedViolations
)
SELECT
    violation_type,
    AVG(days_since_last_violation) AS avg_days_to_reoffend,
    COUNT(*) AS total_repeat_offenses
FROM 
  ViolationGaps
WHERE 
  days_since_last_violation IS NOT NULL -- Exclude the very first violation for each vehicle
GROUP BY 
  violation_type
HAVING 
  COUNT(*) > 50 -- Filter for types with enough data to be significant
ORDER BY 
  avg_days_to_reoffend ASC;
  
 --Q9: Which routes might have equipment problems?
 -- By Bus Route
 SELECT
    bus_route_ID,
    COUNT(*) AS technical_issue_count
FROM
    enforcement_violations
WHERE
    violation_status = 'TECHNICAL ISSUE/OTHER'
    AND bus_route_ID IS NOT NULL
GROUP BY
    bus_route_ID
ORDER BY
    technical_issue_count DESC
LIMIT 20;

  
 
