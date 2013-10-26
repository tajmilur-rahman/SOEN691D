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

my $get_release_dates = $dbh_ref->prepare(q{
	select committer_dt, path as release 
	from git_refs_tags r, git_commit c
	where c.commit = r.commit
	order by committer_dt
});

my $dev_union = $dbh_ref->prepare(q{
	select count(*) 
	from (
		select author, path 
		from dev_area_rel
		where release = ? 
		union
		select author, path 
		from dev_area_rel 
		where release = ?
	) as r
});
my $dev_intersection = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path
		from dev_area_rel
		where release = ?
		INTERSECT
		select author, path 
		from dev_area_rel
		where release = ?
	) as r
});

$get_release_dates->execute() or die;

#throw away the first because nothing is before it
my($prev_date, $prev_release) = $get_release_dates->fetchrow_array;

($prev_date, $prev_release) = $get_release_dates->fetchrow_array;

while ( my($date, $release) = $get_release_dates->fetchrow_array) {

	$dev_union->execute($prev_release, $release) or die;
	my $union = $dev_union->fetchrow_array;
	
	$dev_intersection->execute($prev_release, $release) or die;
	my $intersection = $dev_intersection->fetchrow_array;
	
	my $jac = $intersection/$union;
	my $jac_dist = ($union - $intersection) / $union;
	print " $prev_release ~ $release => $jac_dist\n";
	
	my $query_insert = $dbh_ref->prepare(q{
		insert into rel_jac_dist values(?,?,?)
	});
	$query_insert->execute($prev_release, $release, $jac_dist) or die("Could not insert into rel_jac_dist");

	$prev_date = $date;
	$prev_release = $release;
}

$dev_intersection->finish;
$dev_union->finish;
$get_release_dates->finish;
$dbh_ref->disconnect;

__END__

see dev_jac_releases.sql
