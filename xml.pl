#!/usr/bin/perl -w

use strict;
use XML::Parser;
use Data::Dumper;

my $parser = new XML::Parser( Handlers => {
		Start => \&hdl_start,
		End => \&hdl_end,
		Char => \&hdl_char,
		Default => \&hdl_default,
	}
);

$parser->parsefile("/tmp/fusioninventory.xml");

sub hdl_start {
	my($p, $elt, %attr) = @_;
	#print "start: " . Dumper(\$elt);
}
sub hdl_end {
	my($p, $elt, %attr) = @_;
	#print "end: " . Dumper(\$elt);
}
sub hdl_char {
	my($p, $elt, %attr) = @_;
	#print "char: " . Dumper(\$p);
	my($ap) = $p->{Context};
	my($long) = "";
	foreach ( @$ap ) {
		$long .= "." . $_;
	}
	my($res) = $elt;
	$res =~ s/^\s*//g;
	$res =~ s/\s*$//g;
	return if ( $res eq "" );
	$long =~ s/^\.//;
	$long = lc($long);
	$res = lc($res);
	
	print "$long=$res\n";
}
sub hdl_default {
	my($p, $elt, %attr) = @_;
	#print "default: " . Dumper(\$elt);
}
