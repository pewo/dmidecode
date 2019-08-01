#!/usr/bin/perl -w

use strict;
use Data::Dumper;

sub readfile($) {
        my($file) = shift;
        my(@res) = ();
        if ( open(IN,"<$file") ) {
                foreach ( <IN> ) {
                        chomp;
                        push(@res,$_);
                }
                close(IN);
        }
        return(@res);
}

my(@netstat) = readfile("netstat_-rn");
foreach ( @netstat ) {
	if ( m/(0\.0\.0\.0|default)\s+(
print Dumper(\@netstat);

#ifconfig_-a
