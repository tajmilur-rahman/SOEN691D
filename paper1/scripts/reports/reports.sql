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


# Answer to rq: Are there certain areas of the system that receive increased attention (i.e.\ do developers focus on a smaller set of files around releases)?

# How many churns are made in different release development periods?
select release, count(churn) from dev_area_dev group by release;
  release    | t_churn 
--------------+---------
 linuxv2.6.13 |    3728
 linuxv2.6.14 |    2067
 linuxv2.6.15 |    2017
 linuxv2.6.16 |    3401
 linuxv2.6.17 |    2619
 linuxv2.6.18 |    2963
 linuxv2.6.19 |    4411
 linuxv2.6.20 |    1707
 linuxv2.6.21 |    2647
 linuxv2.6.22 |    2668
 linuxv2.6.23 |    3652
 linuxv2.6.24 |    3713
 linuxv2.6.25 |    3815
 linuxv2.6.26 |    3729
 linuxv2.6.27 |    8135
 linuxv2.6.28 |    2879
 linuxv2.6.29 |    4546
 linuxv2.6.30 |    3511
 linuxv2.6.31 |    3514
 linuxv2.6.32 |    3460
 linuxv2.6.33 |    3076
 linuxv2.6.34 |    8669
 linuxv2.6.35 |    2435
 linuxv2.6.36 |    2090
 linuxv2.6.37 |    2585
 linuxv2.6.38 |    2899
 linuxv2.6.39 |    4452
 linuxv3.0    |    2244
 linuxv3.1    |    1691
 linuxv3.2    |    1951
 linuxv3.3    |    2190
 linuxv3.4    |    1980
 linuxv3.5    |    1737
 linuxv3.6    |    1946
 linuxv3.7    |    2079
 linuxv3.8    |    2844
 linuxv3.9    |    1895
 linuxv3.10   |    1986
 linuxv3.11   |    2065

## How many files get churned during RP of release cycles?
select release,count(distinct path) from dev_area_dev dd where dd.churn>0 group by release;

   release    | files_churned 
--------------+-------
 linuxv2.6.13 |  2938
 linuxv2.6.14 |  1663
 linuxv2.6.15 |  1559
 linuxv2.6.16 |  2565
 linuxv2.6.17 |  2023
 linuxv2.6.18 |  2382
 linuxv2.6.19 |  3314
 linuxv2.6.20 |  1309
 linuxv2.6.21 |  1934
 linuxv2.6.22 |  2053
 linuxv2.6.23 |  2854
 linuxv2.6.24 |  2645
 linuxv2.6.25 |  2812
 linuxv2.6.26 |  2822
 linuxv2.6.27 |  5219
 linuxv2.6.28 |  2058
 linuxv2.6.29 |  3209
 linuxv2.6.30 |  2510
 linuxv2.6.31 |  2630
 linuxv2.6.32 |  2758
 linuxv2.6.33 |  2385
 linuxv2.6.34 |  6797
 linuxv2.6.35 |  2008
 linuxv2.6.36 |  1633
 linuxv2.6.37 |  2069
 linuxv2.6.38 |  2248
 linuxv2.6.39 |  3852
 linuxv3.0    |  1559
 linuxv3.1    |  1325
 linuxv3.10   |  1637
 linuxv3.11   |  1748
 linuxv3.2    |  1561
 linuxv3.3    |  1716
 linuxv3.4    |  1627
 linuxv3.5    |  1419
 linuxv3.6    |  1584
 linuxv3.7    |  1642
 linuxv3.8    |  2447
 linuxv3.9    |  1542

## How many times a file has been committed and churned during release period of release 2.6.13?
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.13' group by release,path) a where t_churn > 0 order by a.t_churn desc;
(results total: 2938), for 2.6.14: 1663, for 3.0: 1566, for 3.2: 1562, for 3.10: 1641 -- we can say it is almost similar for all releases
For 2.6.13
   t_commit         t_churn        
 Min.   : 1.000   Min.   :    0.00  
 1st Qu.: 1.000   1st Qu.:    2.00  
 Median : 1.000   Median :    6.00  
 Mean   : 1.571   Mean   :   44.66  
 3rd Qu.: 2.000   3rd Qu.:   21.00  
 Max.   :76.000   Max.   :28383.00  
                  NA   :    2.00


## Files getting increased attention during release period (churns > 5000):
select count(*) from (select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev group by release,path) a where t_churn > 5000 order by a.release,a.t_churn desc) b group by b.release;

   release    |                      path                       | t_commit | t_churn 
--------------+-------------------------------------------------+----------+---------
 linuxv2.6.13 | drivers/scsi/qla2xxx/ql2322_fw.c                |        1 |   15252
 linuxv2.6.13 | drivers/scsi/qla2xxx/ql2300_fw.c                |        1 |   14387
 linuxv2.6.13 | drivers/scsi/qla2xxx/ql6312_fw.c                |        1 |   12649
 linuxv2.6.13 | drivers/scsi/qla2xxx/ql2200_fw.c                |        1 |   10484
 linuxv2.6.13 | fs/reiserfs/journal.c                           |        2 |    6895
 linuxv2.6.14 | drivers/net/cassini.c                           |        4 |    5849
 linuxv2.6.17 | drivers/scsi/qlogicfc_asm.c                     |        1 |    9751
 linuxv2.6.17 | drivers/net/wan/sdla_x25.c                      |        1 |    5497
 linuxv2.6.17 | drivers/net/wan/sdla_fr.c                       |        1 |    5061
 linuxv2.6.23 | drivers/scsi/advansys.c                         |        1 |   28383
 linuxv2.6.23 | drivers/net/sk98lin/skgepnmi.c                  |        1 |    8210
 linuxv2.6.23 | drivers/net/sk98lin/skge.c                      |        1 |    5219
 linuxv2.6.26 | drivers/media/common/tuners/mxl5005s.c          |       15 |   17052
 linuxv2.6.27 | drivers/net/wireless/ath9k/hw.c                 |        8 |    9157
 linuxv2.6.29 | drivers/net/bnx2_fw2.h                          |        1 |    8795
 linuxv2.6.29 | drivers/net/bnx2_fw.h                           |        1 |    8515
 linuxv2.6.30 | firmware/slicoss/gbdownload.sys.ihex            |        1 |    6148
 linuxv2.6.30 | firmware/slicoss/oasisdownload.sys.ihex         |        1 |    5124
 linuxv2.6.30 | firmware/slicoss/oasisdbgdownload.sys.ihex      |        1 |    5124
 linuxv2.6.32 | drivers/net/e1000/e1000_hw.c                    |        6 |   13686
 linuxv2.6.34 | firmware/bnx2x-e1h-5.2.7.0.fw.ihex              |        1 |   12847
 linuxv2.6.34 | firmware/bnx2x-e1-5.2.7.0.fw.ihex               |        1 |   10178
 linuxv2.6.35 | drivers/staging/xgifb/vb_setmode.c              |        1 |   10736
 linuxv2.6.35 | drivers/edac/i7core_edac.c                      |       76 |    5077
 linuxv3.0    | drivers/scsi/isci/request.c                     |       66 |   13819
 linuxv3.0    | drivers/scsi/isci/core/scic_sds_controller.c    |       48 |   12372
 linuxv3.0    | drivers/scsi/isci/remote_device.c               |       75 |    8323
 linuxv3.0    | drivers/scsi/isci/core/scic_sds_port.c          |       37 |    8264
 linuxv3.0    | drivers/scsi/isci/core/scic_sds_phy.c           |       39 |    8260
 linuxv3.0    | drivers/scsi/isci/host.c                        |       65 |    8129
 linuxv3.0    | drivers/scsi/isci/port.c                        |       51 |    7555
 linuxv3.0    | drivers/scsi/isci/phy.c                         |       34 |    6546
 linuxv3.0    | drivers/scsi/isci/core/scic_sds_request.c       |       43 |    6390
 linuxv3.0    | drivers/scsi/isci/core/scic_sds_remote_device.c |       24 |    6072
 linuxv3.0    | drivers/scsi/isci/task.c                        |       63 |    5108
 linuxv3.11   | drivers/staging/csr/csr_wifi_sme_prim.h         |        1 |    6510
 linuxv3.11   | drivers/staging/csr/csr_wifi_sme_serialize.c    |        1 |    5809

## Files getting increased attention during release period (churns > 1000):
select b.release,count(*) from (select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev group by release,path) a where t_churn > 1000 order by a.release,a.t_churn desc) b group by b.release;

R Summary for the above:
         release       t_churn       
  linuxv2.6.13 : 1   Min.   :  1.00  
  linuxv2.6.14 : 1   1st Qu.:  3.00  
  linuxv2.6.15 : 1   Median : 14.00  
  linuxv2.6.16 : 1   Mean   : 16.78  
  linuxv2.6.17 : 1   3rd Qu.: 20.00  
  linuxv2.6.18 : 1   Max.   :131.00  
 (Other)       :31 

## Highly churned files related to drivers
>1000 churns:621
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev group by release,path) a where t_churn > 1000 order by a.release,a.t_commit desc;
>1000 churns and >5 commits:466
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev group by release,path) a where t_churn > 1000 and t_commit < 5 order by a.release,a.t_commit desc;
>1000 churns of driver files:
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev group by release,path) a where t_churn > 1000 and path ~ E'driver' order by a.release,a.t_commit desc;

## Select developers making how many commits to files in every release preiod
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev group by release,path) a order by a.release,a.t_commit desc;

## Files getting increased attention during release period (commits > 10):
select b.release,count(*) from (select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev group by release,path) a where t_commit > 10 order by a.release,a.t_commit desc) b group by b.release;


## How many files each developer deals with during merge period?
select release,author,count(path) from dev_area_dev dd group by release,author;

How many authors work for a large (>100) number of files?
select release, count(*) from (select release,author,count(path) t_file from dev_area_dev dd group by release,author) a where a.t_file>100 group by a.release;
: in 29 releases out of 39 few authors worked for more than 100 files
    release      t_authors
 linuxv2.6.13 |     4
 linuxv2.6.14 |     2
 linuxv2.6.15 |     2
 linuxv2.6.16 |     3
 linuxv2.6.17 |     1
 linuxv2.6.18 |     3
 linuxv2.6.19 |     5
 linuxv2.6.21 |     1
 linuxv2.6.22 |     2
 linuxv2.6.23 |     3
 linuxv2.6.24 |     1
 linuxv2.6.25 |     3
 linuxv2.6.26 |     1
 linuxv2.6.27 |    10
 linuxv2.6.28 |     1
 linuxv2.6.29 |     3
 linuxv2.6.30 |     3
 linuxv2.6.31 |     2
 linuxv2.6.32 |     3
 linuxv2.6.33 |     1
 linuxv2.6.34 |     6
 linuxv2.6.35 |     1
 linuxv2.6.37 |     2
 linuxv2.6.38 |     3
 linuxv2.6.39 |     1
 linuxv3.0    |     1
 linuxv3.7    |     2
 linuxv3.8    |     1
 linuxv3.11   |     2

Authors working in >100 files in different releases
select * from (select release,author,count(path) t_file from dev_area_dev dd group by release,author) a where a.t_file>100 order by release,author;

We found 5 developers in 5 different release periods worked for extremely high number of files:
 linuxv3.8    | Greg Kroah-Hartman <gregkh@linuxfoundation.org>    |   1114
 linuxv2.6.19 | David Howells <dhowells@redhat.com>                |   1140
 linuxv2.6.27 | Russell King <rmk@dyn-67.arm.linux.org.uk>         |   2426
 linuxv2.6.39 | Lucas De Marchi <lucas.demarchi@profusion.mobi>    |   2466
 linuxv2.6.34 | Tejun Heo <tj@kernel.org>                          |   4222

If we look at their ownership during rp:
linuxv3.8:
select (sum(owned)*100)/count(*) as ownp from (select author,owned from dev_area_dev where author='Greg Kroah-Hartman <gregkh@linuxfoundation.org>' and release='linuxv3.8') a group by author;
Greg Kroah-Hartman owns 70% files he worked

linuxv2.6.19:
David Howells owns only 38% files he worked

linuxv2.6.27:
Russell King owns 70% files he worked

linuxv2.6.39:
Lucas De Marchi owns 64% files he worked

linuxv2.6.34:
Tejun Heo owns 34% files he worked


In how many times authors worked in more than 100 files in a release period?
select author, count(*) from (select * from (select release,author,count(path) t_file from dev_area_dev dd group by release,author) a where a.t_file>100 order by release,author) b group by author;
: We see only 54 developers works in more than 100 files during the release periods of Linux Kernel releases. 2 authors worked in more than 100 files 6 and 5 times, 2 authors 3 times, 7 authors 2 times and rest of the 43 authors worked in >100 files 1 times each.


## Find the jaccard similarity between the sets of files having high focus on them in different releases
Files in linuxv2.6.13 having high attention A:
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.13' group by release,path) a where t_churn > 1000 order by a.release,a.t_churn desc;
Files in linuxv2.6.14 having high attention B:
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.14' group by release,path) a where t_churn > 1000 order by a.release,a.t_churn desc;
Files in linuxv2.6.15 having high attention C:
select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.15' group by release,path) a where t_churn > 1000 order by a.release,a.t_churn desc;

2.6.13~2.6.14: J(A,B) = (AnB)/(AuB): 0
AuB:
(select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.13' group by release,path) a where t_churn > 1000)
union
(select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.14' group by release,path) a where t_churn > 1000);

AnB:
(select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.13' group by release,path) a where t_churn > 1000)
intersect
(select * from (select release,path,sum(commits) t_commit, sum(churn) t_churn from dev_area_dev where release='linuxv2.6.14' group by release,path) a where t_churn > 1000);

2.6.14~2.6.15:
J(B,C) = 0.038 [BnC = 1, BuC = 26]
2.6.15~2.6.16: J(C,D) = 0
2.6.16~2.6.17: J(D,E) = 0
2.6.17~2.6.18: J(E,F) = 0;

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


# What is the Jaccard similarity coeffcient between developers in development period and release period of two consicutive release
for all releases{
	select
		*,cast(r as numeric)/cast(s as numeric) as j
	from
		(select count(*) r from (select distinct author from dev_area_dev where release='linuxv2.6.15' intersect select distinct author from dev_area_dev where release='linuxv2.6.16') b) x,
		(select count(*) s from (select distinct author from dev_area_dev where release='linuxv2.6.15' union select distinct author from dev_area_dev where release='linuxv2.6.16') c) y;
}

# What is the Jaccard similarity coeffcient between files in development period and release period of two consicutive release
for all releases{
	select
		*,cast(r as numeric)/cast(s as numeric) as j
	from
		(select count(*) r from (select distinct path from dev_area_dev where release='linuxv2.6.15' intersect select distinct path from dev_area_dev where release='linuxv2.6.16') b) x,
		(select count(*) s from (select distinct path from dev_area_dev where release='linuxv2.6.15' union select distinct path from dev_area_dev where release='linuxv2.6.16') c) y;
}
