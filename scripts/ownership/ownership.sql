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
    select new_path, count(*) as commits, sum(add+remove) as churn 
    from git_revision r, git_commit c
    where r.commit=c.commit
    group by new_path; 

update file_info set authors = num_authors, first_change = first, last_change = last 
    from (select new_path, count(distinct(author)) as num_authors, min(committer_dt) as first, max(committer_dt) as last 
        from git_commit c, git_revision r 
        where c.commit = r.commit group by new_path
    ) as r where r.new_path = file_info.path;


-- update dev_area_rel dr set ownership = (select ((dr.commits/fi.commits)*100) as ownership from file_info fi where fi.path = dr.path)


