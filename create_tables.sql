--------------------------------------------------------------------------------------
-- PART I - LOADING DATA. 
--------------------------------------------------------------------------------------
-- create a database to work in.
create database ditl;

-- Drop these objects if they already exist in the database.
drop table if exists cms;
drop table if exists cms_part;
drop table if exists cms_qlz;
drop table if exists cms_zlib;
drop table if exists cms_zlib9;
drop table if exists wwearthquakes_lastwk;
drop table if exists cms_load_errors;
drop table if exists cms_bad_key;
drop external table if exists cms_backup;
drop external table if exists cms_export;
drop external table if exists ext_cms;
drop external table if exists ext_wwearthquakes_lastwk;
drop table if exists cms_seq;
drop table if exists cms_p0;
drop sequence if exists myseq;

-- Create the table to hold the cms data from data.gov.  we already know the layout.
drop table if exists cms;
CREATE TABLE cms
(
  car_line_id character varying(20),
  bene_sex_ident_cd numeric(20),
  bene_age_cat_cd bigint,
  car_line_icd9_dgns_cd character varying(10),
  car_line_hcpcs_cd character varying(10),
  car_line_betos_cd character varying(5),
  car_line_srvc_cnt bigint,
  car_line_prvdr_type_cd bigint,
  car_line_cms_type_srvc_cd character varying(5),
  car_line_place_of_srvc_cd bigint,
  car_hcpcs_pmt_amt bigint
)
distributed by (car_line_id);
