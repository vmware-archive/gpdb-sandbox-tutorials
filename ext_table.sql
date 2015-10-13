-- Create an external table that 'points' to the source file.
drop external table if exists ext_cms;
create external table ext_cms (like cms) location ('gpfdist://localhost:8081/2008_cms_data.csv') format 'csv' (header);
