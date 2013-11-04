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

my $get_rc_dates = $dbh_ref->prepare(q{select release, rc_end_date, rel_date from rtr_period});

my $dev_area = $dbh_ref->prepare(q{
	insert into dev_area_rtr
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

$get_rc_dates->execute() or die;

while ( my($release, $rc_end_date, $rel_date) = $get_rc_dates->fetchrow_array) {
	print "$release -- $rc_end_date --  $rel_date\n";

	$dev_area->execute($release, $rc_end_date, $rel_date) or die; 
}

$get_rc_dates->finish;
$dbh_ref->disconnect;

__END__

see dev_area.sql
