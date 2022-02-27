-- Section 1--------------

-- 1.1 ---

-- 1.2.  all the airlines that flew that (JFK-ORD) route in 2018,
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


