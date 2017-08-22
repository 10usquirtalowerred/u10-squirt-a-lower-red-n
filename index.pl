#! /usr/bin/perl -wT

use CGI qw/:standard/;           # load standard CGI routines
print header,                    # create the HTTP header
    start_html('hello world'), # start the HTML
    h1('hello world'),         # level 1 header
    end_html;                  # end the HTML
