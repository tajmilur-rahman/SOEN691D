#How many developers are working for different merge windows in different releases?
select release, count(distinct author) from dev_area_merge group by release;

#How many churns are made in different merge windows in different releases?
select release, sum(churn) from dev_area_merge group by release order by release;

#How many developers are working for different release development period in different releases?
select release, count(distinct author) from dev_area_dev group by release;

#How many churns are made in different release development periods?
select release, count(churn) from dev_area_dev group by release;

#Developers works in both MP and RDP - devs_worked_in_MP_RDP.rpt
(select author from dev_area_merge) intersect (select author from dev_area_dev);

#How many distinct files worked in RDP by each developer
select author,release,count(distinct path) from dev_area_dev group by release,author order by author asc;

#How many distinct files worked in MP by each developer
select author,release,count(distinct path) from dev_area_merge group by release,author order by author asc;

#In life time which files developers are working that they own the file?
select author,path,owned from developer_file_ownership where owned=1;

#In merge periods for all releases which files developers are working that they own the file?
select author,path,owned from dev_area_merge where owned=1;

#In release development periods for all releases which files developers are working that they own the file?
select author,path,owned from dev_area_merge where owned=1;

#Developers total churn and percentage of ownership of the files churned during merge period - dev_churn_ownpercent_MP.rpt
select release,author,sum(churn) as tch,sum(owned) as tw,count(churn) tf, round(cast(sum(owned) as numeric)/count(churn),2)*100 as op from dev_area_merge group by release,author order by release,author;

#Churn vs Ownership Percentage in Merge Period
select release,sum(churn) as tch,sum(owned) as tw,count(churn) tf, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from dev_area_merge group by release order by release;

#What is the percentage of files that a developer worked for in his lifetime
select author, count(path) as files, sum(churn) as tch, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from developer_file_ownership group by author order by author;

#Percentage of working with owned files in MP
select author, count(path) as files, sum(churn) as tch, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from dev_area_merge group by author order by author;

#Percentage of working with owned files in MP and RDP
select b.op as op_MP, a.op as op_RDP

from (
	select author, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from developer_file_ownership group by author order by author
) a, (
	select author, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as op from dev_area_merge group by author order by author
) b

where a.author=b.author;

# Churn frequency of developers in MP
select author,release,round(sum(churn)/count(path),2) as chfrq from dev_area_merge group by release,author;

# Churn percentage in MP and in General of the developers who works in MP
select a.chp as chp_mp

from (
	select author, round(cast(sum(churn) as numeric)/cast(count(path)*100 as numeric),2) as chp from dev_area_merge group by author order by author
) a, (
	select author, round(cast(sum(churn) as numeric)/cast(count(path) as numeric),2) as chp from developer_file_ownership group by author order by author
) b

where a.author=b.author;


