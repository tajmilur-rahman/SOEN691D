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

my $get_auth_info = $dbh_ref->prepare(q{
	select distinct author,path,ownership from developer_file_ownership;
});

my $update_ownership = $dbh_ref->prepare(q{
	update developer_file_ownership set owned = 1 where author = ? and path = ?
});

$get_auth_info->execute() or die;

while (my($author,$path,$ownership) = $get_auth_info->fetchrow_array){
	
	if($ownership > 80){
		print "$author => $path : $ownership\n";
		$update_ownership->execute($author, $path) or die;
	}
}

$get_auth_info->finish;
$update_ownership->finish;
$dbh_ref->disconnect;

__END__




