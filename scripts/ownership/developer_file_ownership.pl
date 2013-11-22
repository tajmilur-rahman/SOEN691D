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
	select distinct author,path from developer_file_ownership;
});

my $get_file_info = $dbh_ref->prepare(q{
	select
		sum(add+remove) as churn,
		count(*) as commits
	from
		git_commit_release cr, git_revision r, git_commit c
	where 
		c.commit = r.commit and r.commit=cr.commit
		and path = ?
	group by new_path;
});

my $update_ownership_ch = $dbh_ref->prepare(q{
	update developer_file_ownership set ownership = ((churn/?)*100)
	where author = ? and path = ?
});
my $update_ownership_cm = $dbh_ref->prepare(q{
	update developer_file_ownership set ownership = ((commits/?)*100)
	where author = ? and path = ?
});

#my @files;

#push @files, $get_file_info->fetchall_arrayref;

#foreach my $row (@files) {
#    foreach my $element (@$row) {
#        print "@$_\n" for $element;
#    }
#}

$get_auth_info->execute() or die;

my $ch0 = 0;
while (my($author,$path) = $get_auth_info->fetchrow_array){
	$get_file_info->execute($path) or die;

	my ($file_total_churn, $file_total_commits) = $get_file_info->fetchrow_array;
	print "$author => $path\n";
	if($file_total_churn == 0){
		print "$ch0. [$path] File total churn is 0\n";
		$update_ownership_cm->execute($file_total_commits, $author, $path) or die;
		$ch0++;
	}else{
		$update_ownership_ch->execute($file_total_churn, $author, $path) or die;
	}
}

$get_auth_info->finish;
$get_file_info->finish;
$update_ownership_ch->finish;
$update_ownership_cm->finish;
$dbh_ref->disconnect;

__END__




