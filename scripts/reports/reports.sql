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
