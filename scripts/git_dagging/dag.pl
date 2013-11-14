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

my $get_revisions = $dbh_ref->prepare(q{
	select	commit, path as release
	from	git_refs_tags
});
my $get_parent = $dbh_ref->prepare(q{
	select	parent
	from	git_dag
	where	child = ?
});

$get_revisions->execute or die;

while ( my($commit, $release) = $get_revisions->fetchrow_array) {
	print "$commit\n";
	_lookupParent($commit);
}

sub _lookupParent($commit)
{
	$get_parent->execute($commit) or die;
	if(my($parent) = $get_parent->fetchrow_array){
		if(_lookupInCommitRelease($parent)){
			# update release number for this commit id
		}else{
			# store
		}
		_lookupParent($parent);
	}else{
		# store
	}
}

sub _lookupInCommitRrelease($commit)
{
	#
	return true;
}

$get_revisions->finish;
$dbh_ref->disconnect;

__END__
