#!/usr/bin/perl -w

package Robot;

use strict;
use Carp;
use Data::Dumper;
use lib ".";
use HashTools;
use Dmidecode;
use Object;

$Robot::VERSION = '0.01';
@Robot::ISA = qw(Object HashTools);

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {};
        bless($self,$class);

	my($dir) = "/local/robot/curr";

        my(%hash) = ( dir => $dir, @_ );
        while ( my($key,$val) = each(%hash) ) {
                $self->set($key,$val);
        }

	$dir = $self->get("dir");
	if ( ! -d $dir ) {
		chdir($dir);
		#croak "$dir: $!";
	}
        return($self);
}

sub readfile() {
	my($self) = shift;
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

sub inventory() {
	my($self) = shift;
	my($target) = shift;
	my($odir) = $self->get("dir");
	my($dir) = $odir . "/$target";
	unless ( -d $dir ) {
		my(@dirs) = ( <$odir/$target*> );
		my($tdir) = shift(@dirs);
		if ( defined($tdir ) ) {
			$dir = $tdir;
		}
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
		# Dmidecode
		#
		my($obj) = new Dmidecode();
		my($dmidecode) = $dir . "/dmidecode";
		my(%dmidecode) = $obj->dmidecode2hash($dmidecode);
	
		$manu = $obj->getfirstmatchingkey(\%dmidecode,"system.information.manufacturer") unless ( $manu );
		$serial = $obj->getfirstmatchingkey(\%dmidecode,"system.information.serial.number") unless ( $serial );
		$model = $obj->getfirstmatchingkey(\%dmidecode,"system.information.product.name") unless ( $model );
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

1;
