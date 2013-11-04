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

my ($prev_release, $release);
my $jac_dist;

my $get_releases = $dbh_ref->prepare(q{
	select distinct p,date from (select substring(path, '(linuxv[0-9]*\.[0-9]?\.?[0-9]*)') as p, date from git_refs_tags) a order by a.date
});

my $query_insert = $dbh_ref->prepare(q{
	insert into jac_dist(release) values(?)
});

# Inserting releases first
$get_releases->execute() or die;
($prev_release) = $get_releases->fetchrow_array;
while ( ($release) = $get_releases->fetchrow_array) {
	if(not $prev_release eq $release){
		#$query_insert->execute($release) or die;
	}
	$prev_release = $release;
}

#************* Calculate Jaccard Distance Between Merge Period and Development Period *******
#****************************** For ALl Releases ********************************************
my $md_union = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path 
		from dev_area_merge
		where release = ? 
		UNION
		select author, path 
		from dev_area_dev 
		where release = ?
	) as r
});
my $md_intersection = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path
		from dev_area_merge
		where release = ?
		INTERSECT
		select author, path 
		from dev_area_dev
		where release = ?
	) as r
});
my $dr_union = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path 
		from dev_area_dev
		where release = ? 
		UNION
		select author, path 
		from dev_area_rtr 
		where release = ?
	) as r
});
my $dr_intersection = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path
		from dev_area_dev
		where release = ?
		INTERSECT
		select author, path 
		from dev_area_rtr
		where release = ?
	) as r
});
my $mr_union = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path 
		from dev_area_merge
		where release = ? 
		UNION
		select author, path 
		from dev_area_rtr 
		where release = ?
	) as r
});
my $mr_intersection = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path
		from dev_area_merge
		where release = ?
		INTERSECT
		select author, path 
		from dev_area_rtr
		where release = ?
	) as r
});

my $query_update = $dbh_ref->prepare(q{
	update jac_dist set jd_merge_dev=?, jd_dev_rtr=?, jd_merge_rtr=? where release=?
});

$get_releases->finish;
$get_releases = $dbh_ref->prepare(q{
	select distinct p,date from (select substring(path, '(linuxv[0-9]*\.[0-9]?\.?[0-9]*)') as p, date from git_refs_tags) a order by a.date
});
$get_releases->execute or die;
($prev_release) = $get_releases->fetchrow_array;
while ( ($release) = $get_releases->fetchrow_array) {
	my $jac_dist_md = 0;
	my $jac_dist_dr = 0;
	my $jac_dist_mr = 0;
	if(not $prev_release eq $release){
		
		$md_union->execute($release, $release) or die;
		my $mdu = $md_union->fetchrow_array;

		$md_intersection->execute($release, $release) or die;
		my $mdi = $md_intersection->fetchrow_array;

		$dr_union->execute($release, $release) or die;
		my $dru = $dr_union->fetchrow_array;

		$dr_intersection->execute($release, $release) or die;
		my $dri = $dr_intersection->fetchrow_array;

		$mr_union->execute($release, $release) or die;
		my $mru = $mr_union->fetchrow_array;

		$mr_intersection->execute($release, $release) or die;
		my $mri = $mr_intersection->fetchrow_array;

		print "$release - ".(($mdi / $mdu) / $mdu)." - ".(($dri / $dru) / $dru)." - ".(($mri / $mru) / $mru)."\n";

		if($mdu > 0){
			$jac_dist_md = ($mdu - $mdi) / $mdu;
		}
		if($dru > 0){
			$jac_dist_dr = ($dru - $dri) / $dru;
		}
		if($mru > 0){
			$jac_dist_mr = ($mru - $mri) / $mru;
		}

		$query_update->execute($jac_dist_md, $jac_dist_dr, $jac_dist_mr, $release) or die("Could not update jac_dist");
	}
	$prev_release = $release;
}

$md_union->finish;
$dr_union->finish;
$mr_union->finish;
$md_intersection->finish;
$dr_intersection->finish;
$mr_intersection->finish;

$query_update->finish;
$query_insert->finish;
$get_releases->finish;
$dbh_ref->disconnect;

__END__

see jac_dist_rel.sql

