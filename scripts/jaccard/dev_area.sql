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

drop table if exists jac_dist_rel;
create table jac_dist_rel (
	release1 text,
	release2 text,
	jac_dist numeric
);
drop table if exists jac_dist;
create table jac_dist (
	release text,
	jd_merge_dev numeric,
	jd_dev_rtr numeric,
	jd_merge_rtr numeric
);
insert into jac_dist select release from stable_releases;

