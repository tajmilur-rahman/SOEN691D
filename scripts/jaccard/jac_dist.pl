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

#************* Calculate Jaccard Distance Between Merge Period and Development Period *******#
#****************************** For ALl Releases ********************************************#
my $md_union = $dbh_ref->prepare(q{
	select count(*)
	from (
		select path 
		from dev_area_merge
		where release = ? 
		UNION
		select path 
		from dev_area_dev 
		where release = ?
	) as r
});
my $md_intersection = $dbh_ref->prepare(q{
	select count(*)
	from (
		select path
		from dev_area_merge
		where release = ?
		INTERSECT
		select path 
		from dev_area_dev
		where release = ?
	) as r
});

my $query_update = $dbh_ref->prepare(q{
	update jac_dist set jd_merge_rel=? where release=?
});

my $get_releases = $dbh_ref->prepare(q{
	select 	release from stable_releases
});

$get_releases->execute or die;
($prev_release) = $get_releases->fetchrow_array;
while ( ($release) = $get_releases->fetchrow_array) {
	my $jac_dist_md = 0;
	if(not $prev_release eq $release){
		
		$md_union->execute($release, $release) or die;
		my $mdu = $md_union->fetchrow_array;

		$md_intersection->execute($release, $release) or die;
		my $mdi = $md_intersection->fetchrow_array;
		
		if($mdu > 0){
			$jac_dist_md = ($mdu - $mdi) / $mdu;
			print "$release - $jac_dist_md\n";
			$query_update->execute($jac_dist_md, $release) or die("Could not update jac_dist");
		}else{
			print "Union is <= 0\n";
		}
	}
	$prev_release = $release;
}

$md_union->finish;
$md_intersection->finish;
$query_update->finish;
$get_releases->finish;

$dbh_ref->disconnect;

__END__
