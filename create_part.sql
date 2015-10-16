drop table if exists players;
CREATE TABLE players
(
name text,
firstname text,
lastname text,
birthcity text,
birthstate text,
birtcounty text,
birthdate date,
college text,
draftteam text,
draftround text,
draftpick text,
draftyear text,
position text,
height text,
weight smallint,
death date,
deathcity text,
deathstate text,
deathcountry text,
rookieyear smallint,
finalyear smallint
)
distributed by (name)
partition by range (draftyear) (START (1936) END (2013) EVERY (5), DEFAULT PARTITION extra);

drop external table if exists ext_players;
create external table ext_players (like players) location ('gpfdist://localhost:8081/players_2013-12-12.csv') format 'csv' (header) LOG ERRORS INTO err_players SEGMENT REJECT LIMIT 1000 ROWS;
