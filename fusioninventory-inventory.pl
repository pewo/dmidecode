#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use lib ".";
use Fusioninventory_Inventory;

my($obj) = new Fusioninventory_Inventory();

my(%hash) = $obj->xml2hash("/tmp/fusioninventory.xml");
my(@keys) = $obj->getallkeys(\%hash,"networks.macaddr");
print Dumper(\@keys);
