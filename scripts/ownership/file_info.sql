\set ECHO all

drop table if exists file_info;
create table file_info (
    path text,
    release text,
    authors numeric,
    commits numeric,
    churn numeric,
    first_change timestamp with time zone,
    last_change timestamp with time zone,
    primary key (path, release)
);

-- update dev_area_rel dr set ownership = (select ((dr.commits/fi.commits)*100) as ownership from file_info fi where fi.path = dr.path)


