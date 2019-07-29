#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use File::Basename;

use FindBin;
use lib $FindBin::Bin;

use myjson;
use mydmidecode;
my($obj) = new myjson;
my($dmi) = new mydmidecode;

my($ansible_cache) = "/local/ansible/cache/ansible_fact_cache/";
my($robot_cache) = "/local/robot/curr/";

sub getallvalues($;@) {
	my($hp) = shift;
	my($value);
	my(@res) = ();
	foreach $value ( @_ ) {
		my($val) = $hp->{$value};
		next unless ( $val );
		next if ( $val =~ /undef|unknown/ );
		push(@res,$val);
	}
	if ( wantarray ) {
		return(@res);
	}
	else {
		return(join(" ",@res));
	}
}
	
sub getfirstvalue($;@) {
	my($hp) = shift;
	my(@res) = getallvalues($hp,@_);
	my($first) = shift(@res);
	return($first);
}

sub ansible_inventory($) {
	my($hp) =  shift;
	my(%inv);
	#
	# Hostname
	#
	my($hostname) = undef;
	$hostname = $hp->{"ansible_hostname"} unless ( $hostname );
	$inv{hostname}=$hostname;

	#
	# Ip
	#
	my($ip) = undef;
	$ip = $hp->{"ansible_default_ipv4.address"} unless ( $ip );
	$inv{ip}=$ip;

	#
	# os/version
	#
	my($os) = undef;
	$os = $hp->{"ansible_distribution"} unless ( $os );

	my($version) = undef;
	$version = $hp->{"ansible_distribution_version"} unless ( $version );

	$inv{os}="$os $version";

	#
	# domain
	#
	my($domain) = undef;
	$domain = getallvalues($hp,"ansible_domain","ansible_dns.search","ansible_dns.domain","ansible_fqdn");
	if ( $domain ) {
		if ( $domain =~ /pdom/ ) {
			$domain = "pdom";
		}
		elsif ( $domain =~ /ericsson/ ) {
			$domain = "fhi";
		}
		else {
			$domain = "unknown";
		}
	}
	$inv{domain}=$domain;


	#
	# MAC
	#
	my($mac) = undef;
	$mac = $hp->{"ansible_default_ipv4.macaddress"} unless ( $mac );
	$inv{mac}=$mac;

	return(%inv);
}

sub readfile($) {
	my($file) = shift;
	my(@res) = ();
	if ( open(IN,"<$file") ) {
		foreach ( <IN> ) {
			chomp;
			push(@res,$_);
		}
		close(IN);
	}
	return(@res);
}

sub robot_inventory($) {
	my($target) = shift;
	my($dir) = $robot_cache . "/$target";
	unless ( -d $dir ) {
		my(@dirs) = ( <$robot_cache/$target*> );
		my($tdir) = shift(@dirs);
		if ( defined($tdir ) ) {
			$dir = $tdir;
		}
		#$dir = shift(@dirs);
	}
	unless ( -d $dir ) {
		return(undef);
	}

	my(%inv) = ();

	my($model) = undef;
	my($type) = undef;
	my($manu) = undef;
	my($serial) = undef;
	my($completed) = 0;
	
	if ( ! $completed ) {
		# 
		# SPARC
		#
		my(@uname) = readfile("$dir/uname_-a");
		if ( grep(/sparc/i,@uname) ) {
			if ( $uname[0] =~ /sparc\s+(.*)$/ ) {
				$model = $1;
				if ( $model =~ /SUNW/ ) {
					$manu = "Sun";
				}
			}
			my(@eeprom) = readfile("$dir/eeprom");
			if ( grep(/virtual-console/i,@eeprom) ) {
				$type = "Virtual Server";
			}
			else {
				$type = "Physical Server";
			}

			if ( grep(/virtual/i,@uname) ) {
				$type = "Virtual Server";
			}
			$completed = 1;
		}
	}

	if ( ! $completed ) {
		#
		# Other
		#
		my($dmidecodef) = $dir . "/dmidecode";
		my(%dmidecode) = $dmi->dmidecode2flat($dmidecodef);
		$manu = getfirstvalue(\%dmidecode,"system.information.manufacturer") unless ( $manu );
		$serial = getfirstvalue(\%dmidecode,"system.information.serial.number") unless ( $serial );
		$model = getfirstvalue(\%dmidecode,"system.information.product.name") unless ( $model );
		if ( $manu && $serial && $model ) {
			$completed = 1;
			if ( $model =~ /vmware/i ) {
				$type = "Virtual Server";
			}
			else {
				$type = "Physical Server";
			}
		}
	}

	$inv{manu}=$manu;
	$inv{type}=$type;
	$inv{model}=$model;

	return(%inv);
}

my(@targets) = ();
if ( $#ARGV > -1 ) {
	foreach ( @ARGV ) {
		push(@targets,$_);
	}
}
else {
	foreach ( <$ansible_cache/*> ) {
		push(@targets,$_);
	}
}
		

my($i) = 0;
my($file);
foreach $file ( @targets ) {
	next unless ( defined($file) );
	my($age) = -M $file;
	$age = 99 unless ( $age );

	if ( $age > 3 ) {
		print "Skipping $file no updates...\n";
		next;
	}
	#print "file: $file\n";
	my(%hash) = $obj->json2flathash($file);
	#foreach ( sort keys %hash ) {
		#print "ans: $_ -> $hash{$_}\n";
	#}

	my(%ansinv) = ansible_inventory(\%hash);
	my(%inv) = ();
	foreach ( sort keys %ansinv ) {
		#print "inv: $_ -> $ansinv{$_}\n";
		$inv{$_}=$ansinv{$_};
	}

	my($target) = basename($file);
	my(%robinv) = robot_inventory($target);
	foreach ( sort keys %robinv ) {
		#print "rob $_ -> $robinv{$_}\n";
		$inv{$_}=$robinv{$_};
	}

	$i++;
	my($str) = "Target($i)=$target ";
	foreach ( sort keys %inv ) {
		my($value) = $inv{$_};
		$value = "unknown" unless ( defined($value) );
		$str .= "$_($value) ";
	}
	print $str . "\n";
}
