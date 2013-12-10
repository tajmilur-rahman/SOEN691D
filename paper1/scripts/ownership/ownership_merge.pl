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

my $get_dev_area_merge_info = $dbh_ref->prepare(q{
	select  author, path, release from dev_area_merge
});
my $get_file_info = $dbh_ref->prepare(q{
		select  churn, commits from file_info where release = ? and path = ?
	});
my $update_ownership_ch = $dbh_ref->prepare(q{
	update dev_area_merge set ownership = round(((churn/?)*100), 2)
	where author = ? and path = ? and release = ?
});

$get_dev_area_merge_info->execute or die;

while (my($author, $path, $release) = $get_dev_area_merge_info->fetchrow_array) {

	$get_file_info->execute($release, $path) or die;
	
	my ($file_total_churn, $file_total_commits) = $get_file_info->fetchrow_array;
	$update_ownership_ch->execute($file_total_churn, $author, $path, $release) or die;
}

$get_dev_area_merge_info->finish;
$get_file_info->finish;
$update_ownership_ch->finish;

$dbh_ref->disconnect;

__END__

see file_info.sql
