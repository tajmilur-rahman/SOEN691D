#!/usr/bin/perl -w

use warnings;
use strict;

#This file calculates the area of developers for the life time. How many commits are made
#by an author for a particular file, how many churns are made and what is the percentage of his/her 
#ownership to that file.

use DBI;
use Config::General;

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'config';
}
die "Config file \'$config_path\' does not exist" unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

my $dbh_ref = DBI->connect("dbi:Pg:database=$config{db_name}", '', '', {AutoCommit => 1});

my $dev_area = $dbh_ref->prepare(q{
	insert into developer_file_ownership
        select 
		author,
		r.new_path,
		count(*) as commits,
		sum(add+remove) as churn,
		0
	from 
		git_commit_release cr, git_revision r, git_commit c
                                    
	where 
		c.commit = r.commit
		and r.commit = cr.commit
	group by
		author, r.new_path
});
$dev_area->execute() or die;
$dev_area->finish;
$dbh_ref->disconnect;

__END__

see dev_area.sql
