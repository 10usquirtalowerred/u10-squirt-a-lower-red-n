#! /usr/bin/perl -wT

use strict;
use warnings;
use Data::Dumper;
use JSON;
use Net::Twitter::Lite::WithAPIv1_1;
use Scalar::Util 'blessed';
use WWW::Curl::Easy;

my $DBG = 1;

my $posted   = "../jrcanespostedresults.txt";
my $authfile = "../twitterauth-prod.txt";

if ($DBG) {
    $authfile = "../twitterauth-devqa.txt";
}

unless ( -f $posted ) {
    unless ( open( POSTED, ">$posted" ) ) {
        die "Cannot open file $posted for writing: $!\n";
    }
    close(POSTED);
} ## end unless ( -f $posted )

unless ( open( POSTED, "$posted" ) ) {
    die "Cannot open file $posted for reading: $!\n";
}

my @posted = (<POSTED>);

close(POSTED);

if ($DBG) {
    print "Already posted results...";
    foreach my $posted (@posted) {
        chomp $posted;
        print " $posted";
    }
    print ".\n";
} ## end if ($DBG)

my %auth;

unless ( open( AUTH, "$authfile" ) ) {
    die "cannot open $authfile for reading: $!\n";
}

while (<AUTH>) {
    if ( $_ =~ m/=/ ) {
        $_ =~ s/\ //g;
        my ( $key, $value ) = split( /=/, $_ );
        chomp $value;
        $auth{$key} = $value;
    } ## end if ( $_ =~ m/=/ )
} ## end while (<AUTH>)

close(AUTH);

my $consumer_key    = "$auth{consumer_key}";
my $consumer_secret = "$auth{consumer_secret}";
my $token           = "$auth{token}";
my $token_secret    = "$auth{token_secret}";

my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
);

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
            if ($DBG) {
                print "== $ID = $Name ==\n";
            }

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

                    my $awayname    = $$away{name};
                    my $awayassocid = $$away{associd};
                    my $awayscore   = $$away{score};

                    my $homename    = $$home{name};
                    my $homeassocid = $$home{associd};
                    my $homescore   = $$home{score};

                    my $alreadyposted = 0;
                    if ( grep( /^$gameid$/, @posted ) ) {
                        $alreadyposted = 1;
                    }

                    if (   defined $awayscore
                        && defined $homescore
                        && $alreadyposted == 0 )
                    {

                        if ($DBG) {
                            print "=========================================== "
                              . $gameid
                              . " ==========================================\n";
                        }

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

                        my $wa = " won against ";
                        my $tw = " tied with ";
                        my $lt = " lost to ";
                        my $wlt;
                        my $score;
                        my $url = "http://ryha.org/results.asp?";
                        $url = $url . "team=" . $ID . "&org=RYHA.ORG";
                        if ( $weare eq "away" ) {
                            if ( $awayscore > $homescore ) {
                                $score = " $awayscore-$homescore";
                                $wlt   = $awayname . $wa . $homename . $score;
                            } elsif ( $awayscore == $homescore ) {
                                $score = " $awayscore-$homescore";
                                $wlt   = $awayname . $tw . $homename . $score;
                            } elsif ( $awayscore < $homescore ) {
                                $score = " $awayscore-$homescore";
                                $wlt   = $awayname . $lt . $homename . $score;
                            }
                        } elsif ( $weare eq "both" || $weare eq "neither" ) {
                            if ( $awayscore > $homescore ) {
                                $score = " $awayscore-$homescore";
                                $wlt   = $awayname . $wa . $homename . $score;
                            } elsif ( $awayscore == $homescore ) {
                                $score = " $homescore-$awayscore";
                                $wlt   = $homename . $tw . $awayname . $score;
                            } elsif ( $awayscore < $homescore ) {
                                $score = " $homescore-$awayscore";
                                $wlt   = $homename . $wa . $awayname . $score;
                            }
                        } elsif ( $weare eq "home" ) {
                            if ( $awayscore > $homescore ) {
                                $score = " $homescore-$awayscore";
                                $wlt   = $homename . $lt . $awayname . $score;
                            } elsif ( $awayscore == $homescore ) {
                                $score = " $homescore-$awayscore";
                                $wlt   = $homename . $tw . $awayname . $score;
                            } elsif ( $awayscore < $homescore ) {
                                $score = " $homescore-$awayscore";
                                $wlt   = $homename . $wa . $awayname . $score;
                            }
                        } else {
                            die "This cannot happen!\n";
                        }

                        $wlt =~ s/\ \ /\ /g;
                        my $tweet = "$wlt at $facilityname $url";
                        print "Posting: " . $tweet . "\n";
                        my $result = $nt->update("$tweet");

                        unless ( open( POSTED, ">>$posted" ) ) {
                            die "Cannot open file $posted for appending: $!\n";
                        }

                        print POSTED $gameid . "\n";

                        close(POSTED);
                        exit;
                        sleep(1);
                    } ## end if ( defined $awayscore...)
                    sleep(1);
                } ## end foreach my $game (@$games)
                sleep(1);
            } ## end unless ($error)
            sleep(1);
        } ## end foreach my $Team (@$Teams)
        sleep(1);
    } ## end foreach my $SubDivision (@$SubDivisions)
    sleep(1);
} ## end foreach my $division (@$divisions)
