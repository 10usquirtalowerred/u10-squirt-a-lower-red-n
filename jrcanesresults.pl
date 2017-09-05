#! /usr/bin/perl -wT

use strict;
use warnings;
use Data::Dumper;
use JSON;

unless ( open ( FILE, "jrcanes.json" )) {
    die "Cannot open JSON file: $!\n";
}

my $jsonstring;

while (<FILE>) {
    $jsonstring = $jsonstring . $_;
}

close(FILE);

#print $jsonstring;

my $jsonhash  = decode_json $jsonstring;

#print Dumper $jsonhash;

my $results = $$jsonhash{results};
#print Dumper $results;

my $games = $$results{games};
#print Dumper $games;

foreach my $game ( @$games ) {
    #print Dumper $game;
    my $away=$$game{away};
    my $facility=$$game{facility};
    my $gameid=$$game{id};
    my $home=$$game{home};
    print "================================================== " .
	$gameid .
	" ==================================================\n";
    my $awayname=$$away{name};
    my $awayassocid=$$away{associd};
    my $awayscore=$$away{score};

    my $homename=$$home{name};
    my $homeassocid=$$home{associd};
    my $homescore=$$home{score};
    
    my $facilityname=$$facility{name};

    my $weare;

    unless($awayassocid) {
	$awayassocid=0;
    }
    unless($homeassocid) {
	$homeassocid=0;
    }
    if ($awayassocid == 3735) {
	$weare = "away";
	if ($homeassocid == 3735) {
	    $weare = "both";
	}
    } elsif ($homeassocid == 3735) {
	$weare = "home";
    } else {
	$weare = "neither";
    }

    my $wlt;
    if ( $weare eq "away" ) {
	if ( $awayscore > $homescore ) {
	    $wlt = "$awayname won against $homename $awayscore-$homescore";
	} elsif ( $awayscore == $homescore ) {
	    $wlt = "$awayname tied with $homename $awayscore-$homescore";
	} elsif ( $awayscore < $homescore ) {
	    $wlt = "$awayname lost to $homename $awayscore-$homescore";
	}
    } elsif ( $weare eq "both" || $weare eq "neither" ) {
	if ( $awayscore > $homescore ) {
	    $wlt = "$awayname won against $homename $awayscore-$homescore";
	} elsif ( $awayscore == $homescore ) {
	    $wlt = "$homename tied with $awayname $homescore-$awayscore";
	} elsif ( $awayscore < $homescore ) {
	    $wlt = "$homename won against $awayname $homescore-$awayscore";
	}
    } elsif ( $weare eq "home" ) {
	if ( $awayscore > $homescore ) {
	    $wlt = "$homename lost to $awayname $homescore-$awayscore";
	} elsif ( $awayscore == $homescore ) {
	    $wlt = "$homename tied with $awayname $homescore-$awayscore";
	} elsif ( $awayscore < $homescore ) {
	    $wlt = "$homename won against $awayname $homescore-$awayscore";
	}
    } else {
	die "This cannot happen!\n";
    }

    $wlt =~ s/\ \ /\ /g;
    print $wlt . " at " . $facilityname . "\n";
    
    
    
    #foreach my $key (keys %$game) {
	#print $key . "\n";
	#print $key . ' = ' . Dumper $$game{$key};
    #}    
}
