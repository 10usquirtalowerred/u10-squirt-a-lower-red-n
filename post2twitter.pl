#! /usr/bin/perl -wT

use strict;
use warnings;
use Net::Twitter::Lite::WithAPIv1_1;
use Scalar::Util 'blessed';

my $authfile = "../twitterauth.txt";
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

my $result = $nt->update('Hello, world, again!');
