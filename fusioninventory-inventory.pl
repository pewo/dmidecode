#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use lib ".";
use Fusioninventory_Inventory;

my($obj) = new Fusioninventory_Inventory();

my(@arr) = $obj->flatten("/tmp/fusioninventory.xml");
#print Dumper(\@arr);
