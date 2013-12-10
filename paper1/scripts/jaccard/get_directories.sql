\set ECHO all

alter table git_revision add column directory text;

update git_revision set directory = substring(new_path, '^(.*)\/.*\.?$');

create index git_rev_dir_idx on git_revision(directory);
