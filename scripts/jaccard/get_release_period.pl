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

my $get_release_dates = $dbh_ref->prepare(q{
	select
		grt.path as release,
		grt.major,
		grt.minor,
		grt.micro,
		grt.rc,
		gc.committer_dt
	from 	
		git_refs_tags grt, git_commit gc 
	where 	
		gc.commit = grt.commit 
	order by
		gc.committer_dt
});

$get_release_dates->execute() or die;

my $prev_release = '';
my $release = '';
my $major = '';
my $minor = '';
my $micro = '';
my $rc = '';
my $release_date = '';
my $prev_release_date = '';
my $start_date = '';
my $end_date = '';
my ($query,$query_handler) = '';
my $type = '';

$get_release_dates->bind_columns(undef, \$release, \$major, \$minor, \$micro, \$rc, \$release_date);

while ( $get_release_dates->fetchrow_array ){
	print "$release :: $major - $minor - ".($micro ? $micro : "")." - ".($rc ? $rc : "")." - $release_date\n";
	if(!$rc){
		if($micro){
			$type = 'micro';
		}else{
			if($minor){
				 $type = 'minor';
			}else{
				 $type = 'major';
			}
		}
	}else{
		$type = 'rc';
	}
	$end_date = $release_date;
	$start_date = $prev_release_date ? $prev_release_date : $release_date;

	$query = "insert into git_rel_period(release, type, start_date, end_date) values('".$release."','".$type."','".$start_date."','".$end_date."')";
	$query_handler = $dbh_ref->prepare($query);
	$query_handler->execute() or die('Could not insert into git_rel_period');
	
	$prev_release_date = $release_date;
	$prev_release = $release;
}

$get_release_dates->finish;
$dbh_ref->disconnect;

__END__

