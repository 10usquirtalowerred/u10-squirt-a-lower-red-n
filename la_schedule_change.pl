#! /usr/bin/perl -wT

use strict;
use warnings;
use POSIX;
use WWW::Curl::Easy;

my $DBG = 1;

my $currentepoch = time();

my $runmins  = 5;
my $onemin   = 60;
my $onehour  = $onemin * 60;
my $twohours = $onehour * 2;
my $oneday   = $onehour * 24;
my $range    = $runmins / 2 * $onemin;

my $onehourhigh  = $currentepoch + $onehour + $range;
my $onehourlow   = $currentepoch + $onehour - $range;
my $twohourshigh = $currentepoch + $twohours + $range;
my $twohourslow  = $currentepoch + $twohours - $range;
my $onedayhigh   = $currentepoch + $oneday + $range;
my $onedaylow    = $currentepoch + $oneday - $range;

my $calendar_url = "http://leagueathletics.com/MySchedule.asp?";
$calendar_url = $calendar_url . "teams=462604&org=RYHA.ORG";
my $calendar_data;

my $browser = WWW::Curl::Easy->new;
$browser->setopt( CURLOPT_VERBOSE,     0 );
$browser->setopt( CURLOPT_HEADER,      0 );
$browser->setopt( CURLOPT_NOPROGRESS,  1 );
$browser->setopt( CURLOPT_TCP_NODELAY, 1 );
$browser->setopt( CURLOPT_URL,         $calendar_url );
$browser->setopt( CURLOPT_POST,        0 );
$browser->setopt( CURLOPT_REFERER,     $calendar_url );
$browser->setopt( CURLOPT_WRITEDATA,   \$calendar_data );
my $retcode = $browser->perform;

if ($DBG) {

    my ( $h1sec, $h1min, $h1hour, $h1mday, $h1mon, $h1year, $h1wday, $h1yday,
        $h1isdst ) = localtime( $currentepoch + $onehour );
    my ( $h2sec, $h2min, $h2hour, $h2mday, $h2mon, $h2year, $h2wday, $h2yday,
        $h2isdst ) = localtime( $currentepoch + $twohours );
    my ( $d1sec, $d1min, $d1hour, $d1mday, $d1mon, $d1year, $d1wday, $d1yday,
        $d1isdst ) = localtime( $currentepoch + $oneday );

    $h1year = $h1year + 1900;
    $h1mon  = $h1mon + 1;
    my $h1AMPM = "AM";
    if ( $h1hour > 11 ) {
        $h1AMPM = "PM";
    }
    if ( $h1hour == 0 ) {
        $h1hour = 12;
    }
    if ( $h1hour > 12 ) {
        $h1hour = $h1hour - 12;
    }
    my $h1end = $h1hour + 1;
    $h1min = sprintf( "%02d", $h1min );

    $h2year = $h2year + 1900;
    $h2mon  = $h2mon + 1;
    my $h2AMPM = "AM";
    if ( $h2hour > 11 ) {
        $h2AMPM = "PM";
    }
    if ( $h2hour == 0 ) {
        $h2hour = 12;
    }
    if ( $h2hour > 12 ) {
        $h2hour = $h2hour - 12;
    }
    my $h2end = $h2hour + 1;
    $h2min = sprintf( "%02d", $h2min );

    $d1year = $d1year + 1900;
    $d1mon  = $d1mon + 1;
    my $d1AMPM = "AM";
    if ( $d1hour > 11 ) {
        $d1AMPM = "PM";
    }
    if ( $d1hour == 0 ) {
        $d1hour = 12;
    }
    if ( $d1hour > 12 ) {
        $d1hour = $d1hour - 12;
    }
    my $d1end = $d1hour + 1;
    $d1min = sprintf( "%02d", $d1min );

    print "One Hour Range: "
      . scalar localtime($onehourlow) . " to "
      . scalar localtime($onehourhigh) . "\n";
    print "Two Hours Range: "
      . scalar localtime($twohourslow) . " to "
      . scalar localtime($twohourshigh) . "\n";
    print "One Day Range: "
      . scalar localtime($onedaylow) . " to "
      . scalar localtime($onedayhigh) . "\n";

    $calendar_data = $calendar_data . "Event One,";
    $calendar_data =
      $calendar_data . "$h1mon/$h1mday/$h1year,$h1hour:$h1min:00 $h1AMPM,";
    $calendar_data =
      $calendar_data . "$h1mon/$h1mday/$h1year,$h1end:$h1min:00 $h1AMPM,";
    $calendar_data = $calendar_data . "FALSE,FALSE,";
    $calendar_data =
      $calendar_data . "$h1mon/$h1mday/$h1year,$h1hour:$h1min:00 $h1AMPM,";
    $calendar_data =
      $calendar_data . ",,,,,10U Squirt A Lower Red - ,Practice - ,Cary,,";
    $calendar_data = $calendar_data . "Normal,FALSE,Normal,4\n";

    $calendar_data = $calendar_data . "Event Two,";
    $calendar_data =
      $calendar_data . "$h2mon/$h2mday/$h2year,$h2hour:$h2min:00 $h2AMPM,";
    $calendar_data =
      $calendar_data . "$h2mon/$h2mday/$h2year,$h2end:$h2min:00 $h2AMPM,";
    $calendar_data = $calendar_data . "FALSE,FALSE,";
    $calendar_data =
      $calendar_data . "$h2mon/$h2mday/$h2year,$h2hour:$h2min:00 $h2AMPM,";
    $calendar_data =
      $calendar_data . ",,,,,10U Squirt A Lower Red - ,Practice - ,Cary,,";
    $calendar_data = $calendar_data . "Normal,FALSE,Normal,4\n";

    $calendar_data = $calendar_data . "Event Three,";
    $calendar_data =
      $calendar_data . "$d1mon/$d1mday/$d1year,$d1hour:$d1min:00 $d1AMPM,";
    $calendar_data =
      $calendar_data . "$d1mon/$d1mday/$d1year,$d1end:$d1min:00 $d1AMPM,";
    $calendar_data = $calendar_data . "FALSE,FALSE,";
    $calendar_data =
      $calendar_data . "$d1mon/$d1mday/$d1year,$d1hour:$d1min:00 $d1AMPM,";
    $calendar_data =
      $calendar_data . ",,,,,10U Squirt A Lower Red - ,Practice - ,Cary,,";
    $calendar_data = $calendar_data . "Normal,FALSE,Normal,4\n";
} ## end if ($DBG)

my @event_lines = split( /\n/, $calendar_data );

foreach my $event_line (@event_lines) {

    #print "$event_line\n";
    my (
        $Subject, $Start_Date, $Start_Time, $End_Date, $End_Time,
        $All_day_event, $Reminder_on_off, $Reminder_Date, $Reminder_Time,
        $Meeting_Organizer, $Required_Attendees, $Optional_Attendees,
        $Meeting_Resources, $Billing_Information, $Categories, $Description,
        $Location, $Mileage, $Priority, $Private, $Sensitivity, $Show_time_as
    ) = split( /,/, $event_line );

    if ( $Start_Time ne "" && $Start_Time ne "Start Time" ) {

        my $map_url = "https://www.google.com/maps/search/" . $Location;
        $map_url =~ s/\ /\+/g;
        if ($DBG) {
            print "\n";
            print "      Date: $Start_Date\n";
            print "      Time: $Start_Time - $End_Time\n";
            print "   Details: $Subject\n";
            print "     Event: $Description\n";
            print "  Location: $Location\n";
            print "   Map URL: $map_url\n";
        } ## end if ($DBG)
        my ( $mon, $mday, $year ) = split( /\//, $Start_Date );
        my ( $Twelve_Hour_Start_Time, $AMPM ) = split( / /, $Start_Time );
        my ( $hour, $min, $sec ) = split( /:/, $Twelve_Hour_Start_Time );

        if ( $AMPM eq "PM" && $hour != 12 ) {
            $hour = $hour + 12;
        }
        my $epoch = mktime( $sec, $min, $hour, $mday, $mon - 1, $year - 1900 );
        my $datetime = scalar localtime($epoch);
        if ($DBG) {
            print "     Epoch: $epoch\n";
            print "Local Time: $datetime\n";
        }

        if ( $onehourlow < $epoch && $epoch < $onehourhigh ) {
            print "One Hour Notification: $Subject\n";
        }

        if ( $twohourslow < $epoch && $epoch < $twohourshigh ) {
            print "Two Hours Notification: $Subject\n";
        }

        if ( $onedaylow < $epoch && $epoch < $onedayhigh ) {
            print "One Day Notification: $Subject\n";
        }

    } ## end if ( $Start_Time ne ""...)
} ## end foreach my $event_line (@event_lines)
