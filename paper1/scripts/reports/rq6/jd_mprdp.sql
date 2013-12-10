\set ECHO all

drop table if exists release_jd_analysis;
create table release_jd_analysis(
	release text,
	j_mp1_rdp1 numeric,
	j_rdp1_rdp2 numeric,
	j_rdp1_mp2 numeric,
	PRIMARY KEY(release)
);
insert into release_jd_analysis select release,0 as a, 0 as b, 0 as c from stable_releases;

select author, path
from dev_area_merge
where release = 'linuxv2.6.14'
INTERSECT
select author, path 
from dev_area_dev
where release = 'linuxv2.6.14'
