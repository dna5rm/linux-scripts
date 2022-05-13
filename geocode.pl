#!/usr/bin/perl

use Geo::Coder::US;
#use Data::Dumper;
use strict;
use warnings;

Geo::Coder::US->set_db( "/home/\@users/GEO/.TIGER2006.db" );

if ($#ARGV != 0) {
    print "usage: geocode.pl \"1600 Pennsylvania Ave, Washington, DC\"\n";
    exit;
}

### Lookup Address ###
my @GEO = Geo::Coder::US->geocode( "$ARGV[0]" );

### Print Output ###
#print Dumper(\@GEO), "\n";
 print "$GEO[0]->{lat},$GEO[0]->{long}\n";

