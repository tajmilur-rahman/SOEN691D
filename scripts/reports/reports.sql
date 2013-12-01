# How many commits belongs to merge period
select count(*) from git_commit_release where release ~ 'rc1';

# How many developers are working for different merge windows in different releases?
select release, count(distinct author) from dev_area_merge group by release;

# How many churns are made in different merge windows in different releases?
select release, sum(churn) from dev_area_merge group by release order by release;

# How many developers are working for different release development period in different releases?
select release, count(distinct author) from dev_area_dev group by release;

# Calculate dev_area_merge
select
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
		and substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)') != 'linuxv2.6.12'
		and substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)') != 'linuxv3.12'
group by
		substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)'), gc.author, gr.new_path;
(results total: 453315 rows)

# Calculate dev_area_dev
select
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
		and substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)') != 'linuxv2.6.12'
		and substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)') != 'linuxv3.12'
group by
		substring(gcr.release, '(linuxv[0-9]\.[0-9]{1,2}\.?[0-9]*)'), gc.author, gr.new_path;
(results total: 119998 rows)

# How many developers work in merge period
select count(distinct author) from dev_area_merge
(results total: 11209)

# How many developers work in release period
select count(distinct author) from dev_area_dev
(results total: 7625)

# How many developers work in both merge window and release period
select count(distinct dd.author) from (select distinct author from dev_area_merge) dm, (select distinct author from dev_area_dev) dd where dm.author=dd.author;
(results total: 4908)

# What is the contribution of developers in merge period and release period per release
select a.release, a.devs as devs_mp, b.devs as devs_rp from (select release, count(author) as devs from dev_area_merge group by release) a, (select release, count(author) as devs from dev_area_dev group by release) b where a.release=b.release order by a.release;


# Select percentage of working in owned files in merge period and percentage of working in owned file in release period (for those who work in both periods)

select	a.ownp as ownp_mp,b.ownp as ownp_rp
from 	(
		select
		author,round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as ownp 
		from 	dev_area_merge 
		group 	by author
		order  	by author
	) a,
	(
		select
		author,round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as ownp 
		from dev_area_dev 
		group by author
		order  by author
	) b
where	a.author=b.author;







# How many churns are made in different release development periods?
select release, count(churn) from dev_area_dev group by release;
(results  total: )

# Developers work in both Merge Period and Release Period - devs_worked_in_MP_RDP.rpt
(select author from dev_area_merge) intersect (select author from dev_area_dev);

# How many distinct files worked in Release Period by each developer
select author,release,count(distinct path) from dev_area_dev group by release,author order by author asc;

# How many distinct files worked in Merge Period by each developer
select author,release,count(distinct path) from dev_area_merge group by release,author order by author asc;

# In the life time which files developers are working that they own the file?
select author,path,owned from developer_file_ownership where owned=1;

# In merge periods for all releases which files developers are working that they own the file?
select author,path,owned from dev_area_merge where owned=1;

# In release development periods for all releases which files developers are working that they own the file?
select author,path,owned from dev_area_merge where owned=1;

# Developers total churn and percentage of ownership of the files churned during merge period - dev_churn_ownpercent_MP.rpt
select release,author,sum(churn) as tch,sum(owned) as tw,count(churn) tf, round(cast(sum(owned) as numeric)/count(churn),2)*100 as op from dev_area_merge group by release,author order by release,author;

# Churn vs Ownership Percentage in Merge Period
select release,sum(churn) as tch,sum(owned) as tw,count(churn) tf, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from dev_area_merge group by release order by release;

# What is the percentage of files that a developer worked for in his lifetime
select author, count(path) as files, sum(churn) as tch, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from developer_file_ownership group by author order by author;

# Percentage of working with owned files in Merge Period
select author, count(path) as files, sum(churn) as tch, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from dev_area_merge group by author order by author;

# Percentage of working with owned files in MP and life time
select b.op as op_MP, a.op as op_RDP

from (
	select author, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from developer_file_ownership group by author order by author
) a, (
	select author, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from dev_area_merge group by author order by author
) b

where a.author=b.author;

# Churn frequency of developers in Merge Period
select author,release,round(sum(churn)/count(path),2) as chfrq from dev_area_merge group by release,author;

# Churn percentage in MP and in General of the developers who works in MP
select a.chp as chp_mp

from (
	select author, round(cast(sum(churn) as numeric)/cast(count(path)*100 as numeric),2) as chp from dev_area_merge group by author order by author
) a, (
	select author, round(cast(sum(churn) as numeric)/cast(count(path) as numeric),2) as chp from developer_file_ownership group by author order by author
) b

where a.author=b.author;


#Percentage of working with owned files in RDP
select author, count(path) as files, sum(churn) as tch, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from dev_area_dev group by author order by author;

# get the average time in advance a commit is made before pushing it to a release?
select r.commit, t.date, c.committer_dt, extract(epoch from t.date - c.committer_dt)/86400 as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit;
select release, avg(extract(epoch from t.date - c.committer_dt)/86400) as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit group by release order by release;

alter table git_refs_tags add column stage text default 'rp';

update git_refs_tags set stage = 'mp' where path ~ 'rc1';

select stage, avg(extract(epoch from t.date - c.committer_dt)/86400) as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit group by stage;

# lag.rpt
select stage, extract(epoch from t.date - c.committer_dt)/86400 as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit

# rp_lag.rpt
select extract(epoch from t.date - c.committer_dt)/86400 as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit and stage = 'rp'

# mp_lag.rpt
select extract(epoch from t.date - c.committer_dt)/86400 as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit and stage = 'mp'



