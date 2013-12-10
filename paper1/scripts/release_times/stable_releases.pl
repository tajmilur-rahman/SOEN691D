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

my $get_release_days = $dbh_ref->prepare(q{
	select
		major, minor, micro,
		min(committer_dt),
		max(committer_dt),
		extract(epoch from max(committer_dt) - min(committer_dt))/86400 num_days
	from
		git_refs_tags r, git_commit c
	where
		c.commit = r.commit
	group by major, minor, micro
	order by major, minor, micro
});
my $insert_query = $dbh_ref->prepare(q{
	insert into stable_releases values(?,?,?,?);
});

$get_release_days->execute() or die;


while ( my($major, $minor, $micro, $start_date, $end_date, $days) = $get_release_days->fetchrow_array ){
	my $release = 'linuxv'.$major.'.'.$minor;
	if($micro){
		$release .= '.'.$micro;
	}
	
	$insert_query->execute($release, $start_date, $end_date, $days) or die('Could not insert into git_rel_period');
}

$get_release_days->finish;
$insert_query->finish;
$dbh_ref->disconnect;

__END__

