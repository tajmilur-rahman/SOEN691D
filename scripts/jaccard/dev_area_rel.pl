#!/usr/bin/perl -w

use warnings;
use strict;

#This file calculates the area of developers during release period. How many commits are made
#by an author for a particular file, how many churns are made and what is the percentage of his/her 
#ownership to that file.

use DBI;
use Config::General;

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'config';
}
die "Config file \'$config_path\' does not exist" unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

my $dbh_ref = DBI->connect("dbi:Pg:database=$config{db_name}", '', '', {AutoCommit => 1});

my $get_release_dates = $dbh_ref->prepare(q{
	select	committer_dt, path as release
	from	git_refs_tags r, git_commit c
	where	c.commit = r.commit
		and r.rc = 0
	order by committer_dt
});
#we are avoiding rc because we want the release dates. rc dates are not release dates.

my $dev_area = $dbh_ref->prepare(q{
	insert into dev_area_rel
        select 
		author,
		?,
		r.new_path,
		count(*) as commits,
		sum(add+remove) as churn,
		0
	from 
		git_revision r, git_commit c
                                    
	where 
		c.commit = r.commit 
		and c.committer_dt > ? 
		and c.committer_dt <= ?
	group by
		author, r.new_path
});
#This will insert the information about the changes that developers are making in a release period.

$get_release_dates->execute() or die;

my($prev_date, $prev_release) = $get_release_dates->fetchrow_array;

while ( my($date, $release) = $get_release_dates->fetchrow_array) {
	print "$release -- $prev_date --  $date\n";

	$dev_area->execute($release, $prev_date, $date) or die; 

	$prev_date = $date;
	$prev_release = $release;
}

$get_release_dates->finish;
$dbh_ref->disconnect;

__END__

see dev_jac_releases.sql
