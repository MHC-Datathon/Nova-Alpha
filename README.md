
--Q1: What is The violation hotstop by station?

    - Violation hotspots

--Q2: How does the distribution of violations differ across the boroughs?

After aggregating the amount of ticket violations by borough, we were able to uncover that the Bronx had the highest amount of violations over the course of the ACE system, with a count of 1,818,310 violations.

    - Violation hotspots

--Q3. What is the rate of repeat offenders?

    - Repeat offenders --> contributing to hotspots

--Q4. What percentage of violators receive more than one ticket within a 12-month period?

    - repeat offenders

--Q5: Is there a strong correlation between specific bus routes and the dominant type of violation they experience?

    - violation type spikes

--Q6: Is there a correlations between ticket counts and low income areas?

    - low income --> violations


# Datathon 2025: Beyond the Bus
<div align='center'>

![](https://media.istockphoto.com/id/157679274/photo/flying-bus-in-the-city-traffic-rush-hour.jpg?s=612x612&w=0&k=20&c=pMXgez4myndKlhDdQQosPowPjkw8Pu3JqUzYo9Bp-x4=)

 A Spatial and Socio-Economic Analysis of MTA Bus Violations
</div>

## Project Overview

<div align='center'>
At the start of 2019, the MTA introduced a new technology with efforts to speed of bus routes in the NYC boroughs. The Bus Automated Camera Enforcement (ACE) system was implemented onto specific buses, eventually spreading onto buses across the five boroughs. 
</div>

### The Team

#### Ibrahima Diallo

  - [LinkedIn](https://www.linkedin.com/in/ibranova/)
  - [GitHub](https://github.com/ibranova)

#### Rolando Mancilla-Rojas
  - [LinkedIn](https://www.linkedin.com/in/rolandoma33/)
  - [GitHub](https://github.com/ro-the-creator)

#### Kabbo Sultan
  - [LinkedIn](https://www.linkedin.com/in/kabbosultan/)
  - [GitHub](https://github.com/kabbosultan)

### Business Problem
Bus lines are consistently slowed by bus lane obstructions, which affect bus efficiency and cause delays. For this reason, the ACE system has been a driving force in waning these issues.
<br>
<br>
Since its inception, there have been over 3 million violations issued, with their implications embedded inside the data. Our team aimed to bring forth these implications, especially in regards to their impact on people and communities.
<br>
<br>
With this goal in mind, this lead our team to 3 overarching questions:
</div>

1. What are the key characteristics of violation hotspots?

2. What are the impacts of repeat offenders on violation rates?

3. Is there a connection between violation frequency and the socio-economic factors of their corresponding bus stops?

-----

## Overview of Database & Schema
This project utilizes a **single, comprehensive table** named `enforcement_violations`. This "flat file" structure contains detailed records for each enforcement event, whether it resulted in a violation or not. This design allows for flexible aggregation and analysis across multiple dimensions like time, location, and vehicle behavior.
  * The data is captured at the level of a single enforcement event, uniquely identified by `violation_ID`.
  * Analysis is conducted by grouping and filtering on key descriptive columns like `bus_route_ID`, `stop_name`, `violation_status`, and `violation_type`.
### Key Columns Overview
  * `vehicle_ID`: A unique identifier for each vehicle.
  * `bus_route_ID`: The bus route on which the event occurred.
  * `stop_name`: The name of the nearest bus stop.
  * `first_occurrence`: The timestamp of the enforcement event.
  * `violation_status`: The outcome of the event (e.g., 'VIOLATION ISSUED', 'EXEMPT', 'TECHNICAL ISSUE/OTHER').
  * `violation_type`: The specific category of the violation (e.g., 'Bus Lane Violation').
  * `bus_stop_latitude`, `bus_stop_longitude`: Geographic coordinates of the bus stop.
-----
## EDA (SQL)
Exploratory Data Analysis was performed to establish a baseline understanding of the enforcement landscape. Three key areas were investigated:
1.  **Violation Status Distribution:** We analyzed the different outcomes of enforcement events. While 'VIOLATION ISSUED' was the most common, a significant number were logged as 'EXEMPT' or 'TECHNICAL ISSUE/OTHER', highlighting the need to filter for issued violations to analyze true offender behavior.
2.  **Geographic Hotspots:** We ran an initial aggregation of violations by bus stop. The analysis immediately revealed a highly skewed distribution: a small number of bus stops are responsible for a disproportionately large number of total violations, confirming the "hotspot" theory.
3.  **Repeat Offender Prevalence:** We performed an initial calculation on repeat vehicles and found that a substantial percentage of vehicles receive more than one ticket. This confirmed that targeting repeat offenders is a viable and potentially high-impact strategy.
-----
## Data Cleaning & Feature Engineering (SQL)
To prepare the data for deep analysis, critical cleaning and feature engineering steps were performed.
### Data Cleaning
The primary data quality issue was the non-standard date format.
  * **Parsing Timestamps:** The `first_occurrence` column was stored as text in the format `MM/DD/YYYY HH:MM:SS PM`. We used `SUBSTR()` functions to parse and reformat this text into a standard `YYYY-MM-DD` format that SQLite's date functions could process.

### Feature Engineering

New features were created to unlock temporal and behavioral insights:
  * `day_type`: Categorized timestamps into 'Weekday' or 'Weekend'. Rationale: To analyze if violation patterns differ between workdays and weekends.
  * `hour_of_day`: Extracted the hour from the timestamp. Rationale: To identify peak violation times for targeted deployment.
  * `days_since_last_violation`: Calculated the time gap between a vehicle's consecutive violations. Rationale: To quantify the "recidivism rate" and understand offender habits.
-----
## CTEs & Window Functions (SQL)
Advanced SQL queries using Common Table Expressions (CTEs) and window functions were essential for uncovering complex patterns.
1.  **Dominant Violation by Route:** We used `ROW_NUMBER()` to find the single most common violation type for every bus route, revealing route-specific challenges.
    ```sql
    SELECT
        bus_route_ID,
        violation_type,
        ROW_NUMBER() OVER (PARTITION BY bus_route_ID ORDER BY COUNT(violation_ID) DESC) as rn
    FROM enforcement_violations
    ```
2.  **Recidivism Rate Analysis:** We used `LAG()` to access the date of a vehicle's previous violation, allowing us to calculate the average time it takes for an offender to get another ticket.
    ```sql
    SELECT
        violation_date,
        LAG(violation_date, 1) OVER (PARTITION BY vehicle_ID ORDER BY violation_date) AS previous_violation_date
    FROM FormattedViolations
    ```
-----
## Visuals (Python)
*Figure 1: Violation Hotspots Across NYC.* This interactive map visualizes the concentration of issued violations, clearly identifying the key corridors and bus stops that are epicenters of enforcement activity and require immediate attention.
*Figure 2: Peak Violation Hours (Weekday vs. Weekend).* This time-series analysis reveals the city's "violation rhythm," showing distinct peaks during weekday commutes (8-10 AM, 4-6 PM) and a different, broader pattern on weekends. This provides a clear guide for when to schedule enforcement patrols.
*Figure 3: Dominant Violation Profile by Bus Route.* This chart provides the core strategic insight, color-coding routes by their primary enforcement challenge. It makes it easy to see that routes in one area might struggle with 'Bus Lane Violations,' while others face 'Parking at Bus Stop' issues, proving a one-size-fits-all strategy is ineffective.
-----
## Insights & Recommendations
### For the Director of NYC Transit
  * **Insight:** Bus lane enforcement is not a uniform problem; it is a series of distinct, predictable challenges concentrated in specific locations, times, and routes. A small group of repeat offenders causes a disproportionate impact.
  * **Recommendation:** **Champion a shift from a volume-based to a targeted, data-driven enforcement model.** Frame this as a strategic initiative to directly improve bus speeds and service reliability, using the "Top 10 Hotspots" as a pilot program to prove effectiveness.
### For the Director of Enforcement Operations
  * **Insight:** Violations are highly predictable. The top 10 bus stops account for a massive portion of all tickets, and peak violation times are consistent. Furthermore, certain routes and vehicles show a high rate of 'Technical Issue' logs, suggesting potential equipment failure.
  * **Recommendations:**
    1.  **Deploy Resources Surgically:** Reallocate enforcement teams to the **Top 10 Hotspots** identified on the map, specifically during the **peak weekday hours** (8-10 AM, 4-6 PM).
    2.  **Target "Super Offenders":** Use the list of top 5% repeat offenders to create a high-priority monitoring list for intervention.
    3.  **Conduct an Equipment Audit:** Launch an investigation into the vehicles and routes with the highest number of 'Technical Issue' logs to ensure camera and system reliability.
### For the Director of Transit Planning
  * **Insight:** The *type* of violation is not random but strongly correlated with the bus route. This suggests that enforcement issues are often symptoms of underlying environmental or infrastructural problems.
  * **Recommendations:**
    1.  **Inform Infrastructure Redesigns:** For routes where 'Bus Lane Violation' is the dominant issue (e.g., M15), use this data to advocate for physical redesigns like protected, red-painted lanes or curb extensions that make incursions more difficult.
    2.  **Review Curbside Policy:** For routes dominated by 'Parking at Bus Stop' or 'Double Parking' violations, partner with the Department of Transportation to review parking regulations, signage clarity, and loading zone policies near the identified hotspot stops.
-----
## Ethics & Bias
  * **Data Quality:** The primary data cleaning challenge was parsing non-standard text-based timestamps. All conversion logic is documented.
  * **Missing Values:** A small percentage of records with `NULL` for `vehicle_id` and `bus_stop_id` were excluded which could slightly underrepresent violations in those areas.
  * **Time Window:** This analysis is based on a specific dataset time frame (2019 - 2024). The findings are highly relevant but should be re-validated with data from different years to check for patterns.
  * **No Severity Modeled:** The analysis treats all issued violations equally. It does not account for the duration or severity of the obstruction, which is a limitation when assessing the true impact on bus service.
-----
## Repo Navigation
  * **/sql:** Contains all SQL scripts for analysis.
  * **/notebooks:** Contains the Python notebook (`visual_analysis.ipynb`) used to generate the visuals.
  * **/figures:** Contains the final PNG image files for the visuals.
  * **/data:** Contains the source `enforcement.db` database file.


