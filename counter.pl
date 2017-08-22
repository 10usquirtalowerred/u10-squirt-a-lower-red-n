#! /usr/bin/perl -wT

use strict;
use warnings;

my $file = "counter.txt";
my $count = 0;

unless ( -f "$file" ) {
    unless ( open (FILE, ">$file") ) {
	die "Cannot create \"$file\" for writing: $!\n";
    }

    print FILE "$count\n";

    close(FILE);
}

if ( -f "$file" ) {
    unless ( open (FILE, "$file") ) {
	die "Cannot open \"$file\" for reading: $!\n";
    }
} else {
    die "Cannot find file \"$file\": $!\n";
}
    
while (<FILE>) {
    $count = $_;
}

close(FILE);

chomp $count;
print "Old Count: $count\n";
$count = $count + 1;
print "New Count: $count\n";

if ( -f "$file" ) {
    unless ( open (FILE, ">>$file") ) {
	die "Cannot open \"$file\" for appending: $!\n";
    }
} else {
    die "Cannot find file \"$file\": $!\n";
}

print FILE "$count\n";

close(FILE);
