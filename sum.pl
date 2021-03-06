#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use File::Basename;
use lib "dmidecode";
use Fusioninventory_Inventory;
use Robot;
use Ansible;

my($ansdir) = "./ansible_fact_cache";
my($ansible) = new Ansible( dir => $ansdir );

my($robdir) = "./curr";
my($robot) = new Robot( dir => $robdir );

my($se_version);
foreach $se_version ( <$robdir/*/se_version> ) {
	my($target) = basename(dirname($se_version));
	print "\nse_version: $se_version, target: $target\n";

	my(%inv) = $robot->inventory($target);
	foreach ( sort keys %inv ) {
		print "$_\t$inv{$_}\n";
	}

	(%inv) = $ansible->inventory($target);
	foreach ( sort keys %inv ) {
		print "$_\t$inv{$_}\n";
	}
}

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
