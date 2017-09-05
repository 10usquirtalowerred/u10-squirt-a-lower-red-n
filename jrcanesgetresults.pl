#! /usr/bin/perl -wT

use strict;
use warnings;
use Data::Dumper;
use JSON;
use WWW::Curl::Easy;

my $referer = 'https://api.leagueathletics.com/';
my $season  = 19149;
my $org     = "RYHA.ORG";

my $divisions_url = $referer . "api/divisions";
$divisions_url = $divisions_url . "?season=" . $season . "&org=" . $org;

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

my $divisions = decode_json $divisions_data;

foreach my $division (@$divisions) {

    my $SubDivisions = $$division{SubDivisions};

    foreach my $SubDivision (@$SubDivisions) {

        my $Teams = $$SubDivision{Teams};

        foreach my $Team (@$Teams) {

            my $ID   = $$Team{ID};
            my $Name = $$Team{Name};
            print "== $ID = $Name ==\n";

            my $results_url = $referer . "api/results";
            $results_url = $results_url . "?TeamID=" . $ID . "&org=" . $org;

            my $results_data;

            $browser->setopt( CURLOPT_URL,       $results_url );
            $browser->setopt( CURLOPT_REFERER,   $referer );
            $browser->setopt( CURLOPT_WRITEDATA, \$results_data );
            $retcode = $browser->perform;

            my $results = decode_json $results_data;

            my $error = $$results{error};

            unless ($error) {
                my $result = $$results{results};

                my $games = $$result{games};

                foreach my $game (@$games) {

                    my $away     = $$game{away};
                    my $facility = $$game{facility};
                    my $gameid   = $$game{id};
                    my $home     = $$game{home};
                    print "================================================== "
                      . $gameid
                      . " ==================================================\n";
                    my $awayname    = $$away{name};
                    my $awayassocid = $$away{associd};
                    my $awayscore   = $$away{score};

                    my $homename    = $$home{name};
                    my $homeassocid = $$home{associd};
                    my $homescore   = $$home{score};

                    my $facilityname = $$facility{name};

                    my $weare;

                    unless ($awayassocid) {
                        $awayassocid = 0;
                    }
                    unless ($homeassocid) {
                        $homeassocid = 0;
                    }
                    if ( $awayassocid == 3735 ) {
                        $weare = "away";
                        if ( $homeassocid == 3735 ) {
                            $weare = "both";
                        }
                    } elsif ( $homeassocid == 3735 ) {
                        $weare = "home";
                    } else {
                        $weare = "neither";
                    }

                    my $wlt;
                    if ( $weare eq "away" ) {
                        if ( $awayscore > $homescore ) {
                            $wlt =
"$awayname won against $homename $awayscore-$homescore";
                        } elsif ( $awayscore == $homescore ) {
                            $wlt =
"$awayname tied with $homename $awayscore-$homescore";
                        } elsif ( $awayscore < $homescore ) {
                            $wlt =
"$awayname lost to $homename $awayscore-$homescore";
                        }
                    } elsif ( $weare eq "both" || $weare eq "neither" ) {
                        if ( $awayscore > $homescore ) {
                            $wlt =
"$awayname won against $homename $awayscore-$homescore";
                        } elsif ( $awayscore == $homescore ) {
                            $wlt =
"$homename tied with $awayname $homescore-$awayscore";
                        } elsif ( $awayscore < $homescore ) {
                            $wlt =
"$homename won against $awayname $homescore-$awayscore";
                        }
                    } elsif ( $weare eq "home" ) {
                        if ( $awayscore > $homescore ) {
                            $wlt =
"$homename lost to $awayname $homescore-$awayscore";
                        } elsif ( $awayscore == $homescore ) {
                            $wlt =
"$homename tied with $awayname $homescore-$awayscore";
                        } elsif ( $awayscore < $homescore ) {
                            $wlt =
"$homename won against $awayname $homescore-$awayscore";
                        }
                    } else {
                        die "This cannot happen!\n";
                    }

                    $wlt =~ s/\ \ /\ /g;
                    print "$wlt at $facilityname\n";

                    #foreach my $key (keys %$game) {
                    #print $key . "\n";
                    #print $key . ' = ' . Dumper $$game{$key};
                    #}
                } ## end foreach my $game (@$games)

            } ## end unless ($error)

            sleep(1);
        } ## end foreach my $Team (@$Teams)
    } ## end foreach my $SubDivision (@$SubDivisions)
} ## end foreach my $division (@$divisions)
