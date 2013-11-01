\set ECHO all

drop table if exists rel_period;
create table rel_period (
	release text,
	type text,
        start_date date,
        end_date date
);

drop table if exists merge_period;
create table merge_period (
	release text,
        major numeric,
        minor numeric,
        micro numeric,
        previous timestamp with time zone,
        rc_date timestamp with time zone,
	days not null default 0
);

drop table if exists rd_period;
create table rd_period (
	release text,
        major numeric,
        minor numeric,
        micro numeric,
        rc_date timestamp with time zone,
        rel_date timestamp with time zone,
	days integer not null default 0
);


drop table if exists rc_period;
create table rtr_period (
	release text,
        major numeric,
        minor numeric,
        micro numeric,
        rc_end_date timestamp with time zone,
        rel_date timestamp with time zone,
	days integer not null default 0
);

--select
--	major, minor, micro,
--	min(committer_dt),
--	max(committer_dt),
--	extract(epoch from max(committer_dt) - min(committer_dt))/86400 num_days
--from 	git_refs_tags r, git_commit c
--where	c.commit = r.commit
--group by major, minor, micro
--order by major, minor, micro;
