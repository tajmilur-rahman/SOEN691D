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

my $select_dev_area = $dbh_ref->prepare(q{
        select 
		author,
		release,
		path,
		ownership
	from 
		dev_area_dev                                   
});
my $update = $dbh_ref->prepare(q{
	update dev_area_dev set owned = 1 where author=? and release=? and path=?
});
$select_dev_area->execute() or die;

while ( my($author, $release, $path, $ownership) = $select_dev_area->fetchrow_array) {
	print "$author, $release, $path, $ownership\n";
	if($ownership > 80){
		print "$author - $release -- $ownership\n";
		$update->execute($author, $release, $path) or die;
	}
}

$select_dev_area->finish;
$update->finish;
$dbh_ref->disconnect;

__END__

