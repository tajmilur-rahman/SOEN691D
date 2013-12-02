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
my $union = $dbh_ref->prepare(q{
	select count(*)
	from (
		select path from (select path, sum(churn) as t_churn from dev_area_dev where release=? group by path) a where t_churn > 1000
		UNION
		select path from (select path, sum(churn) as t_churn from dev_area_dev where release=? group by path) a where t_churn > 1000
	) as e
});
my $intersection = $dbh_ref->prepare(q{
	select count(*)
	from (
		select path from (select path, sum(churn) as t_churn from dev_area_dev where release=? group by path) a where t_churn > 1000
		INTERSECT
		select path from (select path, sum(churn) as t_churn from dev_area_dev where release=? group by path) a where t_churn > 1000
	) as f
});

my $get_releases = $dbh_ref->prepare(q{
	select release from stable_releases;
});

$get_releases->execute or die;
($prev_release) = $get_releases->fetchrow_array;
my $i=0;
print "release_pair | Jaccard_index\n";
while (($release) = $get_releases->fetchrow_array) {
	my $jac = 0;
	if(not $prev_release eq $release){

		$union->execute($prev_release, $release) or die;
		my $aub = $union->fetchrow_array;

		$intersection->execute($prev_release, $release) or die;
		my $anb = $intersection->fetchrow_array;
		
		if($aub > 0){
			$jac = $anb / $aub;
			print "$prev_release~$release | $jac\n";
		}else{
			print "a u b is <= 0\n";
		}
	}
	$prev_release = $release;
	$i++;
}

$union->finish;
$intersection->finish;
$get_releases->finish;
$dbh_ref->commit;
$dbh_ref->disconnect;

__END__

