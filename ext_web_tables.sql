DROP EXTERNAL TABLE IF EXISTS ext_weather;
create external web table ext_weather (like weather)
Execute 'wget -qO - https://github.com/Pivotal-Open-Source-Hub/gpdb-sandbox-tutorials/blob/master/data/weather_2013.csv?raw=true' on all format 'csv' (header) 
LOG ERRORS INTO err_weather segment reject limit 100;
