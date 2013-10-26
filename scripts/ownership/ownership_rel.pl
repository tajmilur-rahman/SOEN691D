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

my $get_file_info = $dbh_ref->prepare(q{
	select	path, churn from file_info
});

my $update_ownership = $dbh_ref->prepare(q{
	update dev_area_rel set ownership = ((churn/?)*100) where author = author and path=?
});

$get_file_info->execute() or die;

while ( my($path, $churn) = $get_file_info->fetchrow_array) {
	$update_ownership->execute($churn, $path) or die; 
}

$get_file_info->finish;
$update_ownership->finish;
$dbh_ref->disconnect;

__END__

see ownership.sql
