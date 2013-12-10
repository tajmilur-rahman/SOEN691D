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

my $rel_churn_ownper = $dbh_ref->prepare(q{
	select author, count(path) as files, sum(churn) as tch, round(cast(sum(owned) as numeric)/cast(count(path) as numeric),2)*100 as wp 
	from dev_area_merge 
	where release='linuxv2.6.13' 
	group by author order by author;
});
my $insert = $dbh_ref->prepare(q{insert into dev_churn_ownp_cumul values(?,?,?,?)});

$rel_churn_ownper->execute() or die;

my $i=0;
my ($totalFiles,$totalChurn,$totalOwnPercent) = 0;
while(my($author,$files,$tch,$wp) = $rel_churn_ownper->fetchrow_array){
	$i++;
	$totalChurn = $totalChurn + $tch;
	$totalFiles = $totalFiles + $files;
	$totalOwnPercent = $totalOwnPercent + $wp;
	if($i%10==0){
		$insert->execute($i,$totalFiles/10,$totalOwnPercent/10,$totalChurn/10);
	}
}

$rel_churn_ownper->finish;
$insert->finish;
$dbh_ref->disconnect;

__END__
