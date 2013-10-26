#!/usr/bin/perl -w

use warnings;
use strict;

use DBI;
use Config::General;

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'config';
}
die "Config file \'$config_path\' does not exist"
	unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

my $dbh_ref = DBI->connect("dbi:Pg:database=$config{db_name}", '', '', {AutoCommit => 1});

my $query1 = $dbh_ref->prepare(q{select r.major, r.minor, r.micro, r.rc, r.date from git_refs_tags r, git_commit c where r.commit=c.commit order by c.committer_dt });

my $insert = $dbh_ref->prepare(q{insert into merge_period values (?,?,?,?,?,?)});

$query1->execute or die;

my $prev_date;
while ( my($major, $minor, $micro, $rc, $date) = $query1->fetchrow_array) {
	if(not defined $prev_date){
		 $prev_date = $date;
	}
	if (defined $rc and $rc == 1) {
		my $release = 'linuxv'.$major.'.'.$minor.'.'.$micro;
		print "$release -- $prev_date -- $date\n";
		$insert->execute($release, $major, $minor, $micro, $prev_date, $date);
	}
	$prev_date = $date;
}

$update = $dbh_ref->prepare(q{update merge_period set days = extract(epoch from rc_date - previous)/86400});
$update->execute;

$query1->finish;
$insert->finish;
$update->finish;
$dbh_ref->disconnect;

__END__

