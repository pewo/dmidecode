#!/usr/bin/perl -w

use strict;
use XML::Parser;
use Data::Dumper;

my(%hash);

sub xml2hash() {

	my(%keys);
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
		
		my($i) = $keys{$long};
		if ( defined($i) ) {
			$i++;
			$keys{$long}=$i;
		}
		else {
			$i=0;
			$keys{$long}=0;
		}
		$long .= ".$i";
	
		$hash{$long}=$res;
	}
	my $parser = new XML::Parser( Handlers => {
			Char => \&hdl_char,
		}
	);

	$parser->parsefile("/tmp/fusioninventory.xml");

	return(%hash);
}
