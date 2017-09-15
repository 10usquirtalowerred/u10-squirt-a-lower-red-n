#! /usr/bin/perl -wT

use strict;
use warnings;
use Data::Dumper;
use Net::Twitter::Lite::WithAPIv1_1;
use XML::FeedPP;

my $DBG = 1;

my $posted   = "../jrcanespostednews.txt";
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
    print "Already posted news...";
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
    ssl                 => 1,
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
);

my $rss  = 'http://ryha.org/Feeds/News/?org=RYHA.ORG';
my $feed = XML::FeedPP->new($rss);
if ($DBG) {
    print "Title: ", $feed->title(),   "\n";
    print "Date: ",  $feed->pubDate(), "\n";
}
foreach my $item ( $feed->get_item() ) {
    my $guid = $item->guid();
    my ( $burl, $id ) = split( /\#/, $guid );
    my $title = $item->title();
    my $url   = $item->link();
    $url =~ s/LeagueAthletics\.com/ryha\.org/g;

    if ($DBG) {
        print "=============================\n";
        print "Title: ", $title, "\n";
        print "URL: ",   $url,   "\n";
        print "ID: ",    $id,    "\n";
        print "=============================\n";
    } ## end if ($DBG)

    my $alreadyposted = 0;
    if ( grep( /^$id$/, @posted ) ) {
        $alreadyposted = 1;
    }

    if ( $title ne "" && $url ne "" && $alreadyposted == 0 ) {
        my $tweet       = "$title $url";
        my $tweetlength = length($tweet);

        print "Posting [$tweetlength]: " . $tweet . "\n";
        my $result = $nt->update("$tweet");

        unless ( open( POSTED, ">>$posted" ) ) {
            die "Cannot open file $posted for appending: $!\n";
        }

        print POSTED $id . "\n";

        close(POSTED);
        exit;
        sleep(1);
    } ## end if ( $title ne "" && $url...)
    sleep(1);
} ## end foreach my $item ( $feed->get_item...)
