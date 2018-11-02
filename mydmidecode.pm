#!/usr/bin/perl -w
#
package mydmidecode;

use strict;
use Data::Dumper;
use Carp;

use lib "/opt/plugins/custom";
use Object;
our @ISA = qw(Object);

sub new {
	my($self) = Object::new(@_);

	return($self);
}

sub dmidecode2flat($) {
	my($self) = shift;
	my($file) = shift;
	unless ( defined($file) ) {
		die "dmidecode2flat  needs one parameter: filename\n";
	}

	unless ( open(DMI,"<$file") ) {
		die "Reading file $file: $!\n";
	}

	my(%res) = ();
	my($key) = undef;
	foreach ( <DMI> ) {
		chomp;
		if ( m/^\w+/ ) {
			$key = $_;
			next;
		}
		s/^\s+//;
		if ( m/:/ ) {
			my($subkey,$value)  = split(/:/,$_);
			next unless ( $value );
			$value =~ s/^\s+//;
			my($realkey) = $key;
			$realkey = $realkey . "." . $subkey;
			$realkey = lc($realkey);
			$realkey =~ s/\s+/./g;
			#print "$realkey == $value\n";
			$res{$realkey}=$value;
		}
	}
	close(DMI);

	return(%res);
}
1;
