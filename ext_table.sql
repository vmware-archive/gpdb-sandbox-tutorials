-- Create an external table that 'points' to the source file.
drop external table if exists ext_playbyplay;
create external table ext_playbyplay (like playbyplay) location ('gpfdist://localhost:8081/pbp-2013.csv') format 'csv' (header) LOG ERRORS INTO err_playbyplay SEGMENT REJECT LIMIT 1000 ROWS;
