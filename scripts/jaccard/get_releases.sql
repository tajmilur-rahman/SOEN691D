\set ECHO all

--release candidates
--update git_refs_tags set type = 'rc' where path ~ E'-rc';

--got rid of head revision etc
--delete from git_refs_tags where path !~ E'v\\d';

--all the rest should be major release
--update git_refs_tags set type = 'major' where type is null;

alter table git_refs_tags add column major integer default 0;
alter table git_refs_tags add column minor integer default 0;
alter table git_refs_tags add column micro integer default 0;
alter table git_refs_tags add column rc integer;

--find out the release candidates
update git_refs_tags set rc = cast(substring(path from position('-rc' in path)+3 for 2) as integer) where path ~ E'-rc';

--find out major release version number
update git_refs_tags set major = cast( substring(path, 'v([0-9]+)\.?') as integer);
--find out minor release version number
update git_refs_tags set minor = cast( substring(path, 'v[0-9]+\.([0-9]+)\.?') as integer );
--find out micro release version number
update git_refs_tags set micro = cast(substring(path, 'v[0-9]+\.[0-9]+\.([0-9]+)\-?') as integer);
