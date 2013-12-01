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

my $update = $dbh_ref->prepare(q{
	 update dev_area_merge set owned = case when ownership>80 then 1 else 0 end
});

$update->execute() or die;

$update->finish;
$dbh_ref->disconnect;

__END__

