#! /usr/bin/perl -wT

use strict;
use warnings;
use WWW::Curl::Easy;

my $groupid   = "33232727";
my $tokenfile = "../token.txt";
my $token;
my $referer = 'https://api.groupme.com/';

unless ( -f $tokenfile ) {
    die "Cannot find token file \"$tokenfile\": $!\n";
}

unless ( open( FILE, $tokenfile ) ) {
    die "Cannot open token file \"$tokenfile\" for reading: $!\n";
}

while (<FILE>) {
    $token = $_;
    chomp $token;
}

close(FILE);

unless ( $token =~ m/[A-Za-z0-9]{40}/ ) {
    die "Token \"$token\" is not valid!\n";
}

unless ( open( FILE, "/usr/share/myspell/en_US.dic" ) ) {
    die "Cannot open dictionary file: $!\n";
}

my @words = (<FILE>);

close(FILE);

my $post_url = $referer . "v3/groups/$groupid/messages?token=$token";
my $date     = localtime();

#my $message = "Hello World on $date!  Here is my message:";
my $message = "";
my $randword;
my $wordcount = 5;
my $counter   = 0;
while ( $counter < $wordcount ) {
    $randword = $words[ rand @words ];
    chomp $randword;
    my ( $word, $x ) = split( /\//, $randword );
    $message = $message . $word . "\\n";
    $counter++;
} ## end while ( $counter < $wordcount)

$message =~ s/\\n$//g;

my @chars = ( "A" .. "Z", "a" .. "z", "0" .. "9" );
my $guid;
$guid .= $chars[ rand @chars ] for 1 .. 32;

#print "$message\n";
my $jsonmessage =
  "{\"message\": {\"source_guid\": \"$guid\", \"text\": \"$message\"}}";
print "$jsonmessage\n";

my $browser = WWW::Curl::Easy->new;
$browser->setopt( CURLOPT_VERBOSE,     0 );
$browser->setopt( CURLOPT_HEADER,      0 );
$browser->setopt( CURLOPT_NOPROGRESS,  1 );
$browser->setopt( CURLOPT_TCP_NODELAY, 1 );
$browser->setopt( CURLOPT_URL,         $post_url );
$browser->setopt( CURLOPT_POST,        1 );
$browser->setopt( CURLOPT_POSTFIELDS,  $jsonmessage );
my @postheaders = ();
$postheaders[0] = "Content-Type: application/json";
$browser->setopt( CURLOPT_HTTPHEADER, \@postheaders );
$browser->setopt( CURLOPT_REFERER,    $referer );
my $retcode = $browser->perform;

print "\ndone.\n"
