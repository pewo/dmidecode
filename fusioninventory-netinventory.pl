#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use lib ".";
use Fusioninventory_Netinventory;

my($obj) = new Fusioninventory_Netinventory();

my(@arr) = $obj->flatten("fusioninventory-netinventory.txt");
#print Dumper(\@arr);
