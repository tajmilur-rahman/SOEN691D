\set ECHO all

drop table if exists file_info;
create table file_info (
    path text,
    authors numeric,
    commits numeric,
    churn numeric,
    first_change timestamp with time zone,
    last_change timestamp with time zone,
    primary key (path)
);

insert into file_info (path, commits, churn) 
    select path, count(*) as commits, sum(add+remove) as churn 
        from git_revision 
        where path ~ E'\\.c$' 
        group by path; 

update file_info set authors = num_authors, first_change = first, last_change = last 
    from (select path, count(distinct(author)) as num_authors, min(committer_dt) as first, max(committer_dt) as last 
        from git_commit c, git_revision r 
        where c.commit = r.commit group by path
    ) as r where r.path = file_info.path;

\o '/tmp/file_info'
select authors, commits, churn, extract(epoch from last_change - first_change)/86400 as time_days from file_info;
\o
