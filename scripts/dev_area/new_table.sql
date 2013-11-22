\set ECHO all

drop table if exists merge_commits;
create table merge_commits (
	commit text,
	release text
);
insert into merge_commits (select commit,substring(release,'(linuxv[0-9]\.[0-9]\.?([0-9]{1,2})?)-rc1') as release from git_commit_release where release ~ E'-rc1$');

drop table if exists dev_commits;
create table dev_commits (
	commit text,
	release text
);
insert into dev_commits (select commit,substring(release,'(linuxv[0-9]\.[0-9]\.?([0-9]{1,2})?)-rc[0-9]') as release from git_commit_release where release ~ E'(linuxv[0-9]\.[0-9]\.?([0-9]{1,2})?)');
