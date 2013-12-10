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
	select release from stable_releases
});
my $j = $dbh_ref->prepare(q{
	select
		cast(p as numeric)/cast(t as numeric) as j
	from
		(select count(*) p from (select distinct path from dev_area_merge where release=? intersect select distinct path from dev_area_merge where release=?) b) x1,
		(select count(*) t from (select distinct path from dev_area_merge where release=? union select distinct path from dev_area_merge where release=?) c) x2;
});
$get_releases->execute() or die;

print "jaccard similarity between files in two consicutive merge periods:\n";
my $i=0;
my ($prev_rel) = $get_releases->fetchrow_array;
while(my($rel) = $get_releases->fetchrow_array){
	$j->execute($prev_rel,$rel,$prev_rel,$rel);
	my $jac = $j->fetchrow_array;
	print "$i | $jac\n";
	$prev_rel = $rel;

	$i++;
}

$get_releases->finish;
$j->finish;
$dbh_ref->disconnect;

__END__
