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
alter table dev_area_rel add column owned integer not null default 0;

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
alter table dev_area_merge add column owned integer not null default 0;
insert into dev_area_merge select
		gc.author,
		substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)') as release,
		gr.new_path as path,
		count(gc.commit) as commits,
		sum(gr.add+gr.remove) as churns,
		0 as ownership,
		0 as owned
from
		git_commit_release gcr, git_commit gc, git_revision gr
where
		gcr.commit=gc.commit
		and gc.commit=gr.commit
		and gcr.release ~ E'rc1$'
group by
		substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)'), gc.author, gr.new_path;

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
alter table dev_area_dev add column owned integer not null default 0;
insert into dev_area_dev select
		gc.author,
		substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)') as release,
		gr.new_path as path,
		count(gc.commit) as commits,
		sum(gr.add+gr.remove) as churns,
		0 as ownership,
		0 as owned
from
		git_commit_release gcr, git_commit gc, git_revision gr
where
		gcr.commit=gc.commit
		and gc.commit=gr.commit
		and gcr.release !~ E'rc1$'
group by
		substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)'), gc.author, gr.new_path;

drop table if exists jac_dist;
create table jac_dist (
	release text,
	jd_merge_rel numeric
);
insert into jac_dist select release from stable_releases;

