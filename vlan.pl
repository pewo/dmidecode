#!/usr/bin/perl -w

use strict;
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin;
use Vlan;

my($vlan) = new Vlan( db => "/home/peter/NFS/git/dmidecode/testdata/vlan.csv" );
#print Dumper(\$vlan);


#my(@vlans) = $vlan->vlanid();
#foreach ( @vlans ) {
#	print "Id: $_\n";
#}

#my(@vlan) = $vlan->content();
#foreach ( @vlan ) {
#	print Dumper(\$_);
#}

#my($res) = $vlan->ip("130.100.1.1");
my($res) = $vlan->ip("192.168.1.123");
my($addr) = $res->{addr};
print "cidr: " . $addr->cidr() . "\n";
print "first: " . $addr->first() . "\n";
print "last: " . $addr->last() . "\n";
print "bcast: " . $addr->broadcast() . "\n";
print "mask: " . $addr->mask() . "\n";
print Dumper(\$res);
