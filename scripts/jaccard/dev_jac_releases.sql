\set ECHO all

drop table if exists dev_area_rel;
create table dev_area_rel (
	author text not null,
	release text, -- current release,
	path text,
	commits numeric,
	churn numeric,
	ownership numeric,
	PRIMARY KEY (author, release, path)
);

drop table if exists dev_area_merge;
create table dev_area_merge (
	author text not null,
	release text, -- current release
	path text,
	commits numeric,
	churn numeric,
	ownership numeric,
	PRIMARY KEY (author, release, path)
);

drop table if exists dev_area_dev;
create table dev_area_dev (
	author text not null,
	release text, -- current release
	path text,
	commits numeric,
	churn numeric,
	ownership numeric,
	PRIMARY KEY (author, release, path)
);

drop table if exists dev_area_rtr;
create table dev_area_rtr (
	author text not null,
	release text, -- current release
	path text,
	commits numeric,
	churn numeric,
	ownership numeric,
	PRIMARY KEY (author, release, path)
);

drop table if exists rel_jac_dist;
create table rel_jac_dist (
	release1 text,
	release2 text,
	jac_dist numeric
);
