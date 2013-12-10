\set ECHO all

alter table git_refs_tags add column date timestamp with time zone;
update git_refs_tags set date = committer_dt from git_commit c where c.commit = git_refs_tags.commit;

