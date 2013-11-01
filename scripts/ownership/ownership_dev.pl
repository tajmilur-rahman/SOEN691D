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

my $get_dev_area_dev_info = $dbh_ref->prepare(q{
	select  author, path, release from dev_area_dev
});
my $get_file_info = $dbh_ref->prepare(q{
		select  churn, commits from file_info where release = ? and path = ?
	});
my $update_ownership_ch = $dbh_ref->prepare(q{
	update dev_area_dev set ownership = ((churn/?)*100)
	where author = ? and path = ? and release = ?
});
my $update_ownership_cm = $dbh_ref->prepare(q{
	update dev_area_dev set ownership = ((commits/?)*100)
	where author = ? and path = ? and release = ?
});

$get_dev_area_dev_info->execute or die;
my $ch0 = 0;
while (my($author, $path, $release) = $get_dev_area_dev_info->fetchrow_array) {

	$get_file_info->execute($release, $path) or die;
	
	my ($file_total_churn, $file_total_commits) = $get_file_info->fetchrow_array;

	if($file_total_churn == 0){
		print "$ch0. [$path] File total churn is 0\n";
		$update_ownership_cm->execute($file_total_commits, $author, $path, $release) or die;
		$ch0++;
	}else{
		$update_ownership_ch->execute($file_total_churn, $author, $path, $release) or die;
	}
}

$get_dev_area_dev_info->finish;
$get_file_info->finish;

$update_ownership_ch->finish;
$update_ownership_cm->finish;
$dbh_ref->disconnect;

__END__

see file_info.sql
