
-- Section 1--------------
-- all the airlines that flew that (JFK-ORD) route in 2018,
-- what is the textual name of each airline and the average departure delay in
-- minutes for that route, in order of smallest delay to largest delay.

SELECT Airline, AVG(dep_delay) AS "Average Delay in Minutes"
FROM (
  SELECT Description as Airline, flight_date, dep_delay FROM all_flights_nocancel
  where origin='JFK' AND DEST='ORD' AND  flight_date>'2017-12-31' AND flight_date<'2019-01-01' AND dep_delay IS NOT NULL
  group by Airline, flight_date, dep_delay
  order by dep_delay ASC
) nested_0
GROUP BY Airline
ORDER BY "Average Delay in Minutes" ASC


-- Section 2 Query Optimization----

-- Step 1: The following query can be executed against the flights PDS to retrieve the earliest scheduled departure time for each airline for each date in the dataset. 

SELECT DISTINCT
    OP_CARRIER,
    FL_DATE,
    (SELECT
LPAD(MIN(CAST(CRS_DEP_TIME AS INTEGER)), 4, 0)
FROM "dremio-tech-challenge"."dremio-tech-challenge".flights i
WHERE i.OP_CARRIER = o.OP_CARRIER AND i.FL_DATE = o.FL_DATE ) as earliest_scheduled_departure
FROM "dremio-tech-challenge"."dremio-tech-challenge".flights o ORDER BY FL_DATE ASC, OP_CARRIER ASC



-- Section 3 Dashboard Simulation ----
----------------------
-- Preparation layer:
-- flights.csv
SELECT fl_date, op_carrier, OP_CARRIER_FL_NUM, ORIGIN, DEST, CRS_DEP_TIME, DEP_TIME, DEPARTURE_DELAY, TAXI_OUT, WHEELS_OFF, WHEELS_ON, TAXI_IN, CRS_ARR_TIME, ARR_TIME, ARR_DELAY, CANCELLED, CANCELLATION_CODE, DIVERTED, CRS_ELAPSED_TIME, ACTUAL_ELAPSED_TIME, AIR_TIME, CONVERT_TO_FLOAT(DISTANCE, 1, 1, 0) AS DISTANCE, CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY
FROM (
  SELECT TO_DATE(fl_date, 'YYYY-MM-DD', 1) AS fl_date, op_carrier, OP_CARRIER_FL_NUM, ORIGIN, DEST, CRS_DEP_TIME, DEP_TIME, CONVERT_TO_FLOAT(DEP_DELAY, 1, 1, 0) AS DEPARTURE_DELAY, TAXI_OUT, WHEELS_OFF, WHEELS_ON, TAXI_IN, CRS_ARR_TIME, ARR_TIME, ARR_DELAY, CANCELLED, CANCELLATION_CODE, DIVERTED, CRS_ELAPSED_TIME, ACTUAL_ELAPSED_TIME, AIR_TIME, DISTANCE, CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY
  from "dremio-tech-challenge"."dremio-tech-challenge".flights
  where cancelled='0.0' AND  fl_date>'2017-12-31' AND fl_date<'2019-01-01'
) nested_0

-- unique_carriers ----
SELECT Code AS airline_code, Description AS airline_name
FROM "dremio-tech-challenge"."dremio-tech-challenge"."unique_carriers.json"

-- airport_master_coordinates ---
SELECT AIRPORT_SEQ_ID, AIRPORT_ID, AIRPORT, DISPLAY_AIRPORT_NAME, DISPLAY_AIRPORT_CITY_NAME_FULL, AIRPORT_WAC, AIRPORT_COUNTRY_NAME, AIRPORT_COUNTRY_CODE_ISO, AIRPORT_STATE_NAME, AIRPORT_STATE_CODE, AIRPORT_STATE_FIPS, CITY_MARKET_ID, DISPLAY_CITY_MARKET_NAME_FULL, CITY_MARKET_WAC, LAT_DEGREES, LAT_HEMISPHERE, LAT_MINUTES, LAT_SECONDS, CONVERT_TO_FLOAT(LATITUDE, 1, 1, 0) AS LATITUDE, LON_DEGREES, LON_HEMISPHERE, LON_MINUTES, LON_SECONDS, CONVERT_TO_FLOAT(LONGITUDE, 1, 1, 0) AS LONGITUDE, AIRPORT_START_DATE, AIRPORT_THRU_DATE, AIRPORT_IS_CLOSED, AIRPORT_IS_LATEST
FROM "dremio-tech-challenge"."dremio-tech-challenge"."airport_master_coordinates.csv" AS "airport_master_coordinates.csv"


-- Step 1 - Create VDS to Conform to Table Definition

select nested_1.airline_code as airline_code, nested_1.airline_name as airline_name, nested_1.fl_date as fl_date, nested_1.departure_delay as departure_delay, nested_1.route as route, nested_1.distance as distance, nested_1.origin as origin, nested_1.origin_airport_name as origin_airport_name, nested_1.origin_latitude as origin_latitude, nested_1.origin_longitude as origin_longitude, nested_1.dest as dest, join_dest_airport_codes.dest_airport_name as dest_airport_name, join_dest_airport_codes.dest_latitude as dest_latitude, join_dest_airport_codes.dest_longitude as dest_longitude
from (
  select nested_0.airline_code as airline_code, nested_0.airline_name as airline_name, nested_0.fl_date as fl_date, nested_0.dest as dest, nested_0.departure_delay as departure_delay, nested_0.route as route, nested_0.distance as distance, nested_0.origin as origin, join_origin_airport_codes.origin_airport_code as origin_airport_code, join_origin_airport_codes.origin_airport_name as origin_airport_name, join_origin_airport_codes.origin_airport_city_name as origin_airport_city_name, join_origin_airport_codes.origin_airport_country as origin_airport_country, join_origin_airport_codes.origin_latitude as origin_latitude, join_origin_airport_codes.origin_longitude as origin_longitude
  from (
    select airline_code, airline_name, fl_date, origin as origin, dest as dest, departure_delay as departure_delay, route, distance as distance
    from challenge.business.flights_unique_carriers as flights_unique_carriers
  ) nested_0
   left join challenge.business.origin_airport_codes as join_origin_airport_codes on nested_0.origin = join_origin_airport_codes.origin_airport_code
) nested_1
 inner join challenge.business.dest_airport_codes as join_dest_airport_codes on nested_1.dest = join_dest_airport_codes.dest_airport_code

--  Business Layer
-------------------------------------
-- flights_unique_carriers
SELECT  nested_0.route, nested_0.fl_date AS fl_date, nested_0.OP_CARRIER_FL_NUM AS OP_CARRIER_FL_NUM, nested_0.ORIGIN AS ORIGIN, nested_0.DEST AS DEST, nested_0.CRS_DEP_TIME AS CRS_DEP_TIME, nested_0.DEP_TIME AS DEP_TIME, nested_0.DEPARTURE_DELAY AS DEPARTURE_DELAY, nested_0.TAXI_OUT AS TAXI_OUT, nested_0.WHEELS_OFF AS WHEELS_OFF, nested_0.WHEELS_ON AS WHEELS_ON, nested_0.TAXI_IN AS TAXI_IN, nested_0.CRS_ARR_TIME AS CRS_ARR_TIME, nested_0.ARR_TIME AS ARR_TIME, nested_0.ARR_DELAY AS ARR_DELAY, nested_0.CANCELLED AS CANCELLED, nested_0.CANCELLATION_CODE AS CANCELLATION_CODE, nested_0.DIVERTED AS DIVERTED, nested_0.CRS_ELAPSED_TIME AS CRS_ELAPSED_TIME, nested_0.ACTUAL_ELAPSED_TIME AS ACTUAL_ELAPSED_TIME, nested_0.AIR_TIME AS AIR_TIME, nested_0.DISTANCE AS DISTANCE, nested_0.CARRIER_DELAY AS CARRIER_DELAY, nested_0.WEATHER_DELAY AS WEATHER_DELAY, nested_0.NAS_DELAY AS NAS_DELAY, nested_0.SECURITY_DELAY AS SECURITY_DELAY, nested_0.LATE_AIRCRAFT_DELAY AS LATE_AIRCRAFT_DELAY, nested_0.op_carrier AS op_carrier, join_unique_carriers.airline_code AS airline_code, join_unique_carriers.airline_name AS airline_name
FROM (
  SELECT fl_date, op_carrier, OP_CARRIER_FL_NUM, ORIGIN, DEST, CRS_DEP_TIME, DEP_TIME, DEPARTURE_DELAY, TAXI_OUT, WHEELS_OFF, WHEELS_ON, TAXI_IN, CRS_ARR_TIME, ARR_TIME, ARR_DELAY, CANCELLED, CANCELLATION_CODE, DIVERTED, CRS_ELAPSED_TIME, ACTUAL_ELAPSED_TIME, AIR_TIME, DISTANCE, CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY, CONCAT_WS('-', ORIGIN, DEST) as route
  FROM Challenge.Preparation.flights
) nested_0
 INNER JOIN Challenge.Preparation.unique_carriers AS join_unique_carriers ON nested_0.op_carrier = join_unique_carriers.airline_code

-- destination airport codes
SELECT 
AIRPORT as DEST_AIRPORT_CODE,
DISPLAY_AIRPORT_NAME as DEST_AIRPORT_NAME, 
DISPLAY_AIRPORT_CITY_NAME_FULL as DEST_AIRPORT_CITY_NAME,
AIRPORT_COUNTRY_NAME as DEST_AIRPORT_COUNTRY,
LATITUDE as DEST_LATITUDE,
LONGITUDE as DEST_LONGITUDE,
AIRPORT_ID
 FROM airport_master_coordinate 
 
--  origin airport codes
SELECT 
AIRPORT as ORIGIN_AIRPORT_CODE,
DISPLAY_AIRPORT_NAME as ORIGIN_AIRPORT_NAME, 
DISPLAY_AIRPORT_CITY_NAME_FULL as ORIGIN_AIRPORT_CITY_NAME,
AIRPORT_COUNTRY_NAME as ORIGIN_AIRPORT_COUNTRY,
LATITUDE as ORIGIN_LATITUDE,
LONGITUDE as ORIGIN_LONGITUDE,
AIRPORT_ID
 FROM airport_master_coordinate 
 
 
-------------------------------------
-- Application layer
-------------------------------------
-- Flight_Details VDS

select nested_1.airline_code as airline_code, nested_1.airline_name as airline_name, nested_1.fl_date as fl_date, nested_1.departure_delay as departure_delay, nested_1.route as route, nested_1.distance as distance, nested_1.origin as origin, nested_1.origin_airport_name as origin_airport_name, nested_1.origin_latitude as origin_latitude, nested_1.origin_longitude as origin_longitude, nested_1.dest as dest, join_dest_airport_codes.dest_airport_name as dest_airport_name, join_dest_airport_codes.dest_latitude as dest_latitude, join_dest_airport_codes.dest_longitude as dest_longitude
from (
  select nested_0.airline_code as airline_code, nested_0.airline_name as airline_name, nested_0.fl_date as fl_date, nested_0.dest as dest, nested_0.departure_delay as departure_delay, nested_0.route as route, nested_0.distance as distance, nested_0.origin as origin, join_origin_airport_codes.origin_airport_code as origin_airport_code, join_origin_airport_codes.origin_airport_name as origin_airport_name, join_origin_airport_codes.origin_airport_city_name as origin_airport_city_name, join_origin_airport_codes.origin_airport_country as origin_airport_country, join_origin_airport_codes.origin_latitude as origin_latitude, join_origin_airport_codes.origin_longitude as origin_longitude
  from (
    select airline_code, airline_name, fl_date, origin as origin, dest as dest, departure_delay as departure_delay, route, distance as distance
    from challenge.business.flights_unique_carriers as flights_unique_carriers
  ) nested_0
   left join challenge.business.origin_airport_codes as join_origin_airport_codes on nested_0.origin = join_origin_airport_codes.origin_airport_code
) nested_1
 inner join challenge.business.dest_airport_codes as join_dest_airport_codes on nested_1.dest = join_dest_airport_codes.dest_airport_code



