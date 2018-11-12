#!/usr/bin/perl -w
#
package myjson;

use strict;
use Data::Dumper;
use JSON;
use Carp;

use lib "/opt/plugins/custom";
use Object;
use HashTools;
our @ISA = qw(Object HashTools);

sub new {
	my($self) = Object::new(@_);

	return($self);
}

sub mydump {
	my($self) = shift;
	my($text) = shift;
	my($value ) = shift;
	my($str) = "";

	if ( ref($value) eq "HASH" ) {
		foreach ( sort keys %$value ) {
			my($val) = $value->{$_};
			if ( ref($val) ) {
				$str .=  $self->mydump($text . "." . $_,$val);
			}
			else {
				if ( defined($val) ) {
					$str .= "$text.$_ == $val\n";
				}
				else {
					$str .= "$text.$_ == undefined\n";
				}
			}
		}
	}
	elsif ( ref($value) eq "ARRAY" ) {
		my($val);
		foreach $val ( @$value ) {
			if ( ref($val) ) {
				$str .= $self->mydump($text,$val);
			}
			else {
				$str .= "$text == $val\n";
			}
		}
	}
	elsif ( ref($value) ) {
	}
	else {
		$value = "undefined" unless ( $value );
		$str .= "$text == $value\n";
	}
	return($str);
}


sub json2flathash($) {
	my($self) = shift;
	my($file) = shift;
	unless ( defined($file) ) {
		die "json2flathash needs one parameter: filename\n";
	}

	unless ( open(JSON,"<$file") ) {
		die "Reading file $file: $!\n";
	}

	my($json_text) = "";
	foreach ( <JSON> ) {
		s/^ok:\s+.*\{/{/;
		$json_text .= $_;
	}
	close(JSON);

	my($res) = "";
	my($hash)  = decode_json $json_text;
	my($key);
	foreach $key ( sort keys %$hash ) {
		my($value) = $hash->{$key};
		unless ( defined($value) ) {
			$value = "unknown";
		}
		my($ref) = ref($value);
		#print "\nref: $ref\n";
		$res .= $self->mydump($key,$value);
	}

	my($i) = 0;
	my(%res);
	my(%keys);
	foreach ( split(/\n|\r/,$res) ) {
		$i++;
		my($key,$value) = split(/\s+==\s+/,$_);
		if ( defined($res{$key}) ) {
			my($index) = $keys{$key};
			$index++;
			$keys{$key}=$index;
			$key  = $key . "." . $index;
		}
		$res{$key}=$value;
	}	

	return(%res);
}
1;
