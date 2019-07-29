package Fusioninventory_Inventory;

use strict;
use Carp;
use Data::Dumper;
use XML::Parser;
use FindBin;
use lib $FindBin::Bin;

use HashTools;
use Object;

$Fusioninventory_Inventory::VERSION = '0.01';
@Fusioninventory_Inventory::ISA = qw(Object HashTools);

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {};
        bless($self,$class);

        my(%hash) = @_;
        while ( my($key,$val) = each(%hash) ) {
                $self->set($key,$val);
        }

        return($self);
}

sub read() {
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

{
	my(%hash);
	my(%keys);

	sub xml2hash() {
		my($self) = shift;
		my($input) = shift;

		%hash = ();
		%keys = ();

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
	
		$parser->parsefile($input);
		return(%hash);
	}
}

sub getallkeys_nope() {
	my($self) = shift;
	my($hp) = shift;
	my(@find) = @_;
	
	my($res) = "";
	my(%keys) = ();
	my($key);
	foreach $key ( keys %$hp ) {
		my($value) = $hp->{$key};
		foreach ( @find ) {
			if ( $key =~ /$_/ ) {
				$res .= $value . " ";
				$keys{$key}=$value;
			}
		}
	}
	$res =~ s/^\s+//;
	$res =~ s/\s+/ /g;
	return($res);
}

1;
