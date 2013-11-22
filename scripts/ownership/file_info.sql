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


drop table if exists developer_file_ownership;
create table developer_file_ownership (
    author text,
    path text,
    commits numeric,
    churn numeric,
    first_change timestamp with time zone,
    last_change timestamp with time zone,
    ownership numeric,
    primary key (author, path)
);
