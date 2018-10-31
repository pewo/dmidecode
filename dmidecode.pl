#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use lib ".";
use Dmidecode;

my($obj) = new Dmidecode();

my($dmidecode) = "dmidecode.txt";
my(%hash) = $obj->flatten($dmidecode);

#my(%keys) = $obj->findkeys(\%hash,"onboard.device.reference.designation");

my($res) = $obj->getallkeys(\%hash,"onboard.device.reference");
print $res . "\n";
#foreach ( sort keys %keys ) {
	#print "$_ -> $keys{$_}\n";
#}
