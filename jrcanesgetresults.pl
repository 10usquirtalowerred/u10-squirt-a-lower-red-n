#! /usr/bin/perl -wT

use strict;
use warnings;
use Data::Dumper;
use JSON;
use WWW::Curl::Easy;

my $referer = 'https://api.leagueathletics.com/';
my $season = 19149;
my $org = "RYHA.ORG";

my $divisions_url = $referer . "api/divisions?season=" . $season . "&org=" . $org;

my $divisions_data;

my $browser = WWW::Curl::Easy->new;
$browser->setopt( CURLOPT_VERBOSE,     0 );
$browser->setopt( CURLOPT_HEADER,      0 );
$browser->setopt( CURLOPT_NOPROGRESS,  1 );
$browser->setopt( CURLOPT_TCP_NODELAY, 1 );
$browser->setopt( CURLOPT_URL,         $divisions_url );
$browser->setopt( CURLOPT_POST,        0 );
$browser->setopt( CURLOPT_REFERER,     $referer );
$browser->setopt( CURLOPT_WRITEDATA,   \$divisions_data );
my $retcode = $browser->perform;

my $divisions  = decode_json $divisions_data;
#print Dumper $divisions;

foreach my $division (@$divisions) {
    #print Dumper $division;

    my $SubDivisions = $$division{SubDivisions};
    #print Dumper $SubDivisions;

    foreach my $SubDivision ( @$SubDivisions ) {
	#print Dumper $SubDivision;

	my $Teams = $$SubDivision{Teams};
	#print Dumper $Teams;

	foreach my $Team ( @$Teams ) {
	    #print Dumper $Team;

	    my $ID = $$Team{ID};
	    my $Name = $$Team{Name};
	    print "$ID = $Name\n";
	}
    }
}
