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

my $dbh_ref = DBI->connect("dbi:Pg:database=$config{db_name}", '', '', {AutoCommit => 0});

my ($prev_release, $release);

#************* Calculate Jaccard Distance Between Merge Period and Development Period *******#
#****************************** For ALl Releases ********************************************#
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

my $dd_union = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path 
		from dev_area_dev
		where release = ? 
		UNION
		select author, path 
		from dev_area_dev 
		where release = ?
	) as r
});
my $dd_intersection = $dbh_ref->prepare(q{
	select count(*)
	from (
		select author, path
		from dev_area_dev
		where release = ?
		INTERSECT
		select author, path 
		from dev_area_dev
		where release = ?
	) as r
});


my $query_update = $dbh_ref->prepare(q{
	update release_jd_analysis set j_mp1_rdp1=?, j_rdp1_rdp2=?, j_rdp1_mp2=? where release=?
});

my $get_releases = $dbh_ref->prepare(q{
	select release from release_jd_analysis;
});

$get_releases->execute or die;
($prev_release) = $get_releases->fetchrow_array;
while (($release) = $get_releases->fetchrow_array) {
	# a = mp1, b = rdp1, c = rdp0
	my $jac_dist_ab = 0;
	my $jac_dist_bc = 0;
	my $jac_dist_ca = 0;

	if(not $prev_release eq $release){

		$md_union->execute($release, $release) or die;
		my $aub = $md_union->fetchrow_array;

		$md_intersection->execute($release, $release) or die;
		my $anb = $md_intersection->fetchrow_array;
		
		$dd_union->execute($release, $prev_release) or die;
		my $buc = $dd_union->fetchrow_array;

		$dd_intersection->execute($release, $prev_release) or die;
		my $bnc = $dd_intersection->fetchrow_array;

		$md_union->execute($release, $prev_release) or die;
		my $cua = $md_union->fetchrow_array;

		$md_intersection->execute($release, $prev_release) or die;
		my $cna = $md_intersection->fetchrow_array;

		if($aub > 0){
			$jac_dist_ab = ($aub - $anb) / $aub;
		}else{
			print "a u b is <= 0\n";
		}

		if($buc > 0){
			$jac_dist_bc = ($buc - $bnc) / $buc;
		}else{
			print "b u c is <= 0\n";
		}

		if($cua > 0){
			$jac_dist_ca = ($cua - $cna) / $cua;
		}else{
			print "c u a is <= 0\n";
		}

		print "$release - $jac_dist_ab, $jac_dist_bc, $jac_dist_ca\n";
		$query_update->execute($jac_dist_ab, $jac_dist_bc, $jac_dist_ca, $release) or die("Could not update jac_dist");
	}
	$prev_release = $release;
}

$md_union->finish;
$md_intersection->finish;
$dd_union->finish;
$dd_intersection->finish;
$query_update->finish;
$get_releases->finish;
$dbh_ref->commit;
$dbh_ref->disconnect;

__END__
