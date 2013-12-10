#!/usr/bin/perl -w

use warnings;
use strict;

use DBI;
use Config::General;

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'config';
}
die "Config file \'$config_path\' does not exist" unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

my $dbh_ref = DBI->connect("dbi:Pg:database=$config{db_name}", '', '', {AutoCommit => 1});

my $update_file_info;

my $get_release_dates = $dbh_ref->prepare(q{
	select	committer_dt, path as release
	from	git_refs_tags r, git_commit c
	where	c.commit = r.commit
		and r.rc = 0
	order by committer_dt
});

my $insert_file_info = $dbh_ref->prepare(q{
	insert into file_info (path, release, authors, commits, churn)
	select 
		distinct new_path,
		?,
		0 as authors,
		count(*) as commits,
		sum(add+remove) as churn
	from
		git_revision r, git_commit c
	where 
		c.commit = r.commit
		and c.committer_dt > ?
		and c.committer_dt <= ?
	group by
		r.new_path
});

$update_file_info = $dbh_ref->prepare(q{
	update file_info set authors = num_authors, first_change = first_ch, last_change = last_ch
	from (
		select 	new_path, count(distinct(author)) as num_authors,
			min(committer_dt) as first_ch,
			max(committer_dt) as last_ch
		from 	git_commit c, git_revision r 
		where 	c.commit = r.commit
			and c.committer_dt > ?
			and c.committer_dt <= ?
		group by new_path
	) as r
	where r.new_path = file_info.path and file_info.release = ?;
});

$get_release_dates->execute or die;
my($prev_date, $prev_release) = $get_release_dates->fetchrow_array;

while(my($date, $release) = $get_release_dates->fetchrow_array){

	$insert_file_info->execute($release, $prev_date, $date) or die; 
	
	$update_file_info->execute($prev_date, $date, $release) or die;

	$prev_date = $date;
	$prev_release = $release;
}

$get_release_dates->finish;
$insert_file_info->finish;
$update_file_info->finish;
$dbh_ref->disconnect;

__END__

see ownership.sql
