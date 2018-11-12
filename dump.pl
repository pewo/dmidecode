#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use File::Basename;
use lib "dmidecode";
use Dmidecode;
use Fusioninventory_Inventory;
use Robot;
use Ansible;

my($robdir) = "./curr";
my($ansdir) = "./ansible_fact_cache";
my($obj);
my($target) = shift;
	

my(%sum) = ();

##################################################
# Robot
##################################################
#print "Robot Inventory\n";
$obj = new Robot( dir => $robdir );
{
	my(%inv) = $obj->inventory($target);
	foreach ( sort keys %inv ) {
		$sum{$_}=$inv{$_};
		print "$_\t$inv{$_}\n";
	}
}

#print "Ansible Facts\n";
$obj = new Ansible( dir => $ansdir );
{
	my(%inv) = $obj->inventory($target);
	foreach ( sort keys %inv ) {
		$sum{$_}=$inv{$_};
		print "$_\t$inv{$_}\n";
	}
}
__END__

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
