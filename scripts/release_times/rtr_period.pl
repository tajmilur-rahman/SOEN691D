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

my($query1, $query2);

$query1 = $dbh_ref->prepare(q{
	select	release, major, minor, micro, (
			select	max(date) as release_date
			from	git_refs_tags
			where	rc != 0 and major=m.major and minor=m.minor and micro=m.micro
			group	by major, minor, micro order by release_date
		) as rc_end_date
	from merge_period m
});

my $insert = $dbh_ref->prepare(q{insert into rtr_period values (?,?,?,?,?,?)});

$query1->execute or die(pg_last_error());

while ( my($release, $major, $minor, $micro, $rc_end_date) = $query1->fetchrow_array) {

	$query2 = $dbh_ref->prepare(q{select max(date) from git_refs_tags where major=? and minor=? and micro=? group by major, minor, micro});
	$query2->execute($major, $minor, $micro) or die(pg_last_error());
	my $release_date = $query2->fetchrow_array;
	
	if(defined $release_date){
		my $release = 'linuxv'.$major.'.'.$minor.'.'.$micro;
		print "$release -- $rc_end_date -- $release_date\n";
		$insert->execute($release, $major, $minor, $micro, $rc_end_date, $release_date);
	}
}

$update = $dbh_ref->prepare(q{update rtr_period set days = extract(epoch from rel_date - rc_end_date)/86400});
$update->execute;

$query1->finish;
$query2->finish;
$insert->finish;
$update->finish;
$dbh_ref->disconnect;

__END__
