--------------------------------------------------------------------------------------
-- PART I - LOADING DATA. 
--------------------------------------------------------------------------------------
-- create a database to work in.
create database tutorialdb;
\c tutorialdb;
-- Drop these objects if they already exist in the database.
drop table if exists playbyplay;
drop table if exists players;
drop table if exists weather;
-- Create the table to hold the cms data from data.gov.  we already know the layout.
CREATE TABLE playbyplay 
(
gameid int,
gamedate date,
quarter smallint,
minute smallint,
second smallint,
offense character varying(3),
defense character varying(3),
down smallint,
togo smallint,
yardline smallint,
filler1 bit,
seriesfirstdown boolean,
filler2 bit,
nextscore smallint,
description text,
teamwin smallint,
filler3 bit,
filler4 bit,
seasonyear smallint,
yards smallint,
formation text,
playtype text,
isrush boolean,
ispass boolean,
isincomplete boolean,
istouchdown boolean,
passtype text,
issack boolean,
ischallenge boolean,
ischallengedreversed boolean,
challenger boolean,
ismeasurement boolean,
isinterception boolean,
isfumble boolean,
ispenalty boolean,
istwopointconversion boolean,
istwopointoconversionsuccessful boolean,
rushdirection text,
yardlinefixed smallint,
yardlinedirection text,
ispenaltyaccepted boolean,
penaltyteam character varying(3),
isnoplay boolean,
penaltytype text,
penaltyyards smallint
)
distributed by (gameid);
