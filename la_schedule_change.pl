#! /usr/bin/perl -wT

use strict;
use warnings;
use POSIX;
use WWW::Curl::Easy;

my $currentepoch = time();

my $runmins = 5;
my $onemin = 60;
my $onehour = $onemin * 60;
my $twohours = $onehour * 2;
my $oneday = $onehour * 24;
my $range = $runmins / 2 * $onemin;

my $onehourhigh = $currentepoch + $onehour + $range; 
my $onehourlow = $currentepoch + $onehour - $range; 
my $twohourshigh = $currentepoch + $twohours + $range; 
my $twohourslow = $currentepoch + $twohours - $range; 
my $onedayhigh = $currentepoch + $oneday + $range; 
my $onedaylow = $currentepoch + $oneday - $range; 

print "One Hour Range: " . scalar localtime ($onehourlow) . " to " . scalar localtime ($onehourhigh) . "\n";
print "Two Hours Range: " . scalar localtime ($twohourslow) . " to " . scalar localtime ($twohourshigh) . "\n";
print "One Day Range: " . scalar localtime ($onedaylow) . " to " . scalar localtime ($onedayhigh) . "\n";

my $calendar_url = "http://leagueathletics.com/MySchedule.asp?teams=462604&org=RYHA.ORG";
my $calendar_data;

my $browser = WWW::Curl::Easy->new;
$browser->setopt( CURLOPT_VERBOSE,     0 );
$browser->setopt( CURLOPT_HEADER,      0 );
$browser->setopt( CURLOPT_NOPROGRESS,  1 );
$browser->setopt( CURLOPT_TCP_NODELAY, 1 );
$browser->setopt( CURLOPT_URL,         $calendar_url);
$browser->setopt( CURLOPT_POST,        0 );
$browser->setopt( CURLOPT_REFERER,     $calendar_url );
$browser->setopt( CURLOPT_WRITEDATA,   \$calendar_data );
my $retcode = $browser->perform;

$calendar_data = $calendar_data . "Event One,8/23/2017,3:45:00 PM,8/23/2017,4:45:00 PM,FALSE,FALSE,8/23/2017,2:45:00 PM,,,,,,10U Squirt A Lower Red - ,Practice - ,Cary,,Normal,FALSE,Normal,4\n";
$calendar_data = $calendar_data . "Event Two,8/23/2017,4:45:00 PM,8/23/2017,5:45:00 PM,FALSE,FALSE,8/23/2017,3:45:00 PM,,,,,,10U Squirt A Lower Red - ,Practice - ,Cary,,Normal,FALSE,Normal,4\n";
$calendar_data = $calendar_data . "Event Three,8/24/2017,2:45:00 PM,8/24/2017,3:45:00 PM,FALSE,FALSE,8/24/2017,1:45:00 PM,,,,,,10U Squirt A Lower Red - ,Practice - ,Cary,,Normal,FALSE,Normal,4\n";
$calendar_data = $calendar_data . "\n";


my @event_lines = split(/\n/, $calendar_data);

foreach my $event_line (@event_lines) {
    #print "$event_line\n";
    my ($Subject, $Start_Date, $Start_Time, $End_Date, $End_Time, $All_day_event, $Reminder_on_off, $Reminder_Date, $Reminder_Time, $Meeting_Organizer, $Required_Attendees, $Optional_Attendees, $Meeting_Resources, $Billing_Information, $Categories, $Description, $Location, $Mileage, $Priority, $Private, $Sensitivity, $Show_time_as) = split(/,/, $event_line);
    
    if ( $Start_Time ne "" &&  $Start_Time ne "Start Time" ) {
	#print "$Subject\n$Start_Date\n$Start_Time\n$End_Date\n$End_Time\n$All_day_event\n$Reminder_on_off\n$Reminder_Date\n$Reminder_Time\n$Meeting_Organizer\n$Required_Attendees\n$Optional_Attendees\n$Meeting_Resources\n$Billing_Information\n$Categories\n$Description\n$Location\n$Mileage\n$Priority\n$Private\n$Sensitivity\n$Show_time_as\n\n";
	print "\n";
	print "      Date: $Start_Date\n";
	print "      Time: $Start_Time - $End_Time\n";
	print "   Details: $Subject\n";
	print "     Event: $Description\n";
	print "  Location: $Location\n";
	my ( $mon, $mday, $year ) = split(/\//, $Start_Date);
	my ( $Twelve_Hour_Start_Time, $AMPM ) = split(/ /, $Start_Time);
	my ( $hour, $min, $sec ) = split(/:/, $Twelve_Hour_Start_Time);
	if ( $AMPM eq "PM" ) {
	    $hour=$hour+12;
	}
	my $epoch = mktime($sec, $min, $hour, $mday, $mon-1, $year-1900);
	print "     Epoch: $epoch\n";
	my $datetime = scalar localtime ($epoch);
	print "Local Time: $datetime\n";

	if ( $onehourlow < $epoch && $epoch < $onehourhigh ) {
	    print "One Hour Notification: $Subject\n";
	}
	
	if ( $twohourslow < $epoch && $epoch < $twohourshigh ) {
	    print "Two Hours Notification: $Subject\n";
	}
	
	if ( $onedaylow < $epoch && $epoch < $onedayhigh ) {
	    print "One Day Notification: $Subject\n";
	}
	
	
    }
}
