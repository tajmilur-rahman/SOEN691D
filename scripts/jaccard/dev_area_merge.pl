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

my $get_merge_dates = $dbh_ref->prepare(q{
	select	release, previous, rc_date
	from	merge_period order by major, minor, micro
});

my $dev_area = $dbh_ref->prepare(q{
	insert into dev_area_merge
        select 
		author,
		?,
		r.new_path,
		count(*) as commits,
		sum(add+remove) as churn,
		0 as ownership
	from 
		git_revision r, git_commit c
                                    
	where 
		c.commit = r.commit 
		and c.committer_dt > ?
		and c.committer_dt <= ?
	group by
		author, r.new_path
});
#This will insert the information about the changes that developers are making in a period of merging in a release.

$get_merge_dates->execute() or die;

while ( my($release, $prev_date, $rc_date) = $get_merge_dates->fetchrow_array) {
	print "$release -- $prev_date --  $rc_date\n";

	$dev_area->execute($release, $prev_date, $rc_date) or die; 
}

$get_merge_dates->finish;
$dbh_ref->disconnect;

__END__

see dev_jac_releases.sql
