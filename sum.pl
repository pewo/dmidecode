#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use lib ".";
use Dmidecode;
use Fusioninventory_Inventory;
use Robot;

my($obj);
##################################################
# Robot
##################################################
$obj = new Robot();
print Dumper(\$obj);
__END__


##################################################
# dmidecode
##################################################
$obj = new Dmidecode();
{
	my($dmidecode) = "dmidecode.txt";
	my(%hash) = $obj->dmidecode2hash($dmidecode);
	
	my(%keys) = $obj->getallmatchingkeys(\%hash,"onboard.device.reference");
	foreach ( sort keys %keys ) {
		print "$_ -> $keys{$_}\n";
	}
}

##################################################
#  Fusioninventory-inventory
##################################################
{
	$obj = new Fusioninventory_Inventory();

	my($fusioninventory) = "/tmp/fusioninventory.xml";
	my(%hash) = $obj->xml2hash($fusioninventory);
	
	#my(%keys) = $obj->getfirstmatchingkey(\%hash,"networks.macaddr");
	#print Dumper(\%keys);
	
	my(%keys) = $obj->getallmatchingkeys(\%hash,"networks.macaddr");
	foreach ( sort keys %keys ) {
		print "$_ -> $keys{$_}\n";
	}
}

##################################################
#  Fusioninventory-Netinventory
##################################################
{
	$obj = new Fusioninventory_Inventory();

	my($fusioninventory) = "fusioninventory-netinventory.txt";
	my(%hash2) = $obj->xml2hash($fusioninventory);
	
	my(%keys2) = $obj->getallmatchingkeys(\%hash2,".");
	foreach ( sort keys %keys2 ) {
		print "$_ -> $keys2{$_}\n";
	}
}
