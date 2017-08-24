#! /usr/bin/perl -wT

use strict;
use warnings;
use CGI qw/:all *table *Tr *td/;

print header,                   # create the HTTP header
  start_html('hello world'),    # start the HTML
  h1('environment'),            # level 1 header
  start_table;

for ( sort keys %ENV ) {
    print start_Tr, start_td, $_, end_td,
      start_td, $ENV{$_}, end_td, end_Tr, "\n";
}

print end_table,
  end_html;                     # end the HTML
