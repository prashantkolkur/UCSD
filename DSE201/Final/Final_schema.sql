drop table if exists teams cascade;
CREATE TABLE teams
(
  name character varying(50) primary key NOT NULL,
  coach character varying(50) NOT NULL unique
  
);

drop table if exists matches cascade;
CREATE TABLE matches
(
  hteam character varying(50) references teams (name) NOT NULL,
  vteam character varying(50) references teams (name) NOT NULL,
  hscore int NOT NULL,
  vscore int NOT NULL,
  primary key (hteam,vteam)
);

