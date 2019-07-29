#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use NetAddr::IP;

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
	vlan => { filename => "testdata/vlan.csv" },
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
	my($primarykey) = $header[0];
	foreach ( <IN> ) {
		chomp;
		next if ( m/^#/ );
		$rec++;
		my(@arr) = split(/$delimiter/,$_);
		my(%hash);
		foreach ( @header ) {
			$hash{$_} = shift(@arr);
		}
		my($host) = $hash{$primarykey};
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
print "HOSTS: " . Dumper(\@hosts) if ( $debug > 8 );

my(@vlan);
my($vlanp) = $data{vlan};
my($vlanid);
my(%vlan);
foreach $vlanid ( keys %$vlanp ) {
	#print "vlanid: $vlanid\n";
	my($network) = $vlanp->{$vlanid}{network};
	next unless ( $network );
	my $ip  = NetAddr::IP->new($network);
	next unless ( $ip );
	$vlan{$vlanid}=$ip;
}
delete($data{vlan});
print "VLAN: " . Dumper(\%vlan) if ( $debug > 8 );

my($cmdb) = $data{cmdb};
print "CMDB: " . Dumper(\$cmdb) if ( $debug > 8 );

my($ad) = $data{ad};
print "AD: " . Dumper(\$ad) if ( $debug > 8 );

my($robot) = $data{robot};
print "ROBOT: " . Dumper(\$robot) if ( $debug > 8 );

my(%res);
my($host);
foreach $host ( sort @hosts ) {
	#print "\nhost: $host\n";
	$res{$host}{host}=$host;

	my($ip) = undef;
	my($os) = undef;
	my($descr) = undef;

	my($db);
	foreach $db ( $robot, $ad, $cmdb ) {
		print "Ref(\$db): " . ref($db) . "\n" if ( $debug > 8 );

		my($dbp) = $ht->getfirstmatchingkeyvalue($db,"^$host");
		print "dbp: " . Dumper(\$dbp) if ( $dbp && $debug > 8);
		$ip = $dbp->{ip} unless ( $ip );
		$os = $dbp->{os} unless ( $os );
		$descr = $dbp->{descr} unless ( $descr );
	}

	$res{$host}{ip}=$ip;
	$res{$host}{os}=$os;
	$res{$host}{descr}=$descr;
	$res{$host}{vlan}="unknown";

	if ( $ip ) {
		my($net);
		$net = NetAddr::IP->new($ip);
		next unless ( $net );
		my($id);
		foreach $id ( keys %vlan ) {
			my($vlannet) = $vlan{$id};
			if ( $net->within($vlannet) ) {
				$res{$host}{vlan}=$id
			}
		}
	}

}

my($header) = undef;
my($res) = undef;
foreach ( sort keys %res ) {
	my($hp) = $res{$_};
	next unless ( $hp );
	my($key);
	my($line) = "";
	foreach $key ( qw(host ip vlan os descr) ) {
		my($val) = $hp->{$key} || "";
		$line .= $OFS . $val;
		$header .= $OFS . $key unless ( $res );
	}
	$res = $header . "\n" unless ( $res );
	$res =~ s/^$OFS//;
	$line =~ s/^$OFS//;
	$res .= $line . "\n";
}

print $res;
__END__
	
print "RES: " . Dumper(\%res);
