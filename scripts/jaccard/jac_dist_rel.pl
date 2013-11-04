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

my $get_releases = $dbh_ref->prepare(q{
	select distinct p,date from (select substring(path, '(linuxv[0-9]*\.[0-9]?\.?[0-9]*)') as p, date from git_refs_tags) a order by a.date
});

my $dev_union = $dbh_ref->prepare(q{
	select count(*) 
	from (
		select author, path 
		from dev_area_rel
		where release = ? 
		UNION
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

my $query_insert = $dbh_ref->prepare(q{
	insert into jac_dist_rel values(?,?,?)
});

my($jac_dist);

$get_releases->execute() or die;

#throw away the first because nothing is before it
my($prev_release) = $get_releases->fetchrow_array;

while ( my($release) = $get_releases->fetchrow_array) {
	if(not $prev_release eq $release){
	
		$dev_union->execute($prev_release, $release) or die;
		my $union = $dev_union->fetchrow_array;

		$dev_intersection->execute($prev_release, $release) or die;
		my $intersection = $dev_intersection->fetchrow_array;

		print "$union - $intersection / $union\n";

		if($union > 0){
			$jac_dist = ($union - $intersection) / $union;
		}else{
			$jac_dist = 0;
		}

		print " $prev_release ~ $release => $jac_dist\n";

		$query_insert->execute($prev_release, $release, $jac_dist) or die("Could not insert into jac_dist_rel");
	}
	$prev_release = $release;
}

$dev_intersection->finish;
$dev_union->finish;
$get_releases->finish;
$dbh_ref->disconnect;

__END__

see jac_dist_rel.sql
