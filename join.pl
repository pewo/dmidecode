#!/usr/bin/perl -w

use strict;
use Data::Dumper;

use lib ".";
use HashTools;

my($debug) = 1;
my($IFS) = ";";
my($OFS) = $IFS;
my($inputs) = 0;
my($input);
my(%delimiter);
my(%filenames);


my($ht) = HashTools->new();
#print Dumper(\$ht);

my(%args) = (
	hosts => { filename => "testdata/hosts.csv" },
	cmdb   => { filename => "testdata/cmdb.csv", delimiter => ";" },
	ad  => { filename => "testdata/ad.csv", delimiter => "," },
	robot  => { filename => "testdata/robot.csv", delimiter => ";" },
);

#
# Handle all inputfiles and their delimiters
#
foreach $input ( sort keys %args ) {
	next unless ( $input );
	#print "Input: $input\n" if ( $debug );
	my($filename) = $args{$input}{filename};
	my($delimiter) = $args{$input}{delimiter};
	next unless ( $filename );
	next unless ( -r $filename );
	$inputs++;
	$delimiter = $IFS unless ( $delimiter );
	#print "Filename[$filename], Delimter[$delimiter]\n" if ( $debug );
	$delimiter{$input}=$delimiter;
	$filenames{$input}=$filename;
}

unless ( $inputs ) {
	#die "Usage: $0 filename(=<IFS>) filename=(<IFS>) filename\nExample: $0 apa=; bepa=, cepa\n";
	die "Error in 0\n";
}

#
# Read file by file
#
my(%data);
foreach $input ( sort keys %filenames ) {
	my($filename) = $filenames{$input};
	unless ( open(IN,"<$filename") ) {
		die "Reading $filename: $!\n";
	}
	
	my($delimiter) = $delimiter{$input};
	$delimiter = $IFS unless ( $delimiter );
	my($rec) = 0;
	my($header) = scalar <IN>;
	chomp($header);
	my(@header) = split(/$delimiter/,$header);
	foreach ( <IN> ) {
		chomp;
		next if ( m/^#/ );
		$rec++;
		my(@arr) = split(/$delimiter/,$_);
		my(%hash);
		foreach ( @header ) {
			$hash{$_} = shift(@arr);
		}
		my($host) = $hash{host};
		$data{$input}{$host}=\%hash;
	}
}

my(@hosts);
my($hostsp) = $data{hosts};
foreach ( keys %$hostsp ) {
	my($hp) = $hostsp->{$_};
	my($host) = $hp->{host};
	push(@hosts,$hp->{host});
}
delete($data{hosts});

my($cmdb) = $data{cmdb};
print "CMDB: " . Dumper(\$cmdb);

my($ad) = $data{ad};
print "AD: " . Dumper(\$ad);

my($robot) = $data{robot};
print "ROBOT: " . Dumper(\$robot);

my(%res);
my($host);
foreach $host ( sort @hosts ) {
	print "\nhost: $host\n";
	$res{$host}{host}=$host;
	my($cmdbp) = $ht->getfirstmatchingkeyvalue($cmdb,"^$host");
	print "cmdb: " . Dumper(\$cmdbp) if ( $cmdbp );

	my($adp) = $ht->getfirstmatchingkeyvalue($ad,"^$host");
	print "ad: " . Dumper(\$adp) if ( $adp );

	my($robotp) = $ht->getfirstmatchingkeyvalue($robot,"^$host");
	print "robot: " . Dumper(\$robotp) if ( $robotp );
}
