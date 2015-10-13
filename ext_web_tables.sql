DROP TABLE IF EXISTS WWearthquakes_lastWk;
CREATE TABLE WWearthquakes_lastWk (
time TEXT, latitude numeric, longitude numeric, depth numeric, mag numeric, mag_type varchar (10),
NST integer, gap numeric, dmin numeric, rms text, net text, id text, updated TEXT, place varchar(150), type varchar(50)
)
DISTRIBUTED BY (time);

DROP EXTERNAL TABLE IF EXISTS ext_WWearthquakes_lastWk;
create external web table ext_WWearthquakes_lastWk (like WWearthquakes_lastWk) 
Execute 'wget -qO - http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.csv'  -- defining an OS command to execute
ON ALL
Format 'CSV' (HEADER)
LOG ERRORS INTO err_earthquakes
Segment Reject limit 300;
