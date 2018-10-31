package Dmidecode;

use strict;
use Carp;
use Data::Dumper;
use lib ".";
use Object;

$Dmidecode::VERSION = '0.01';
@Dmidecode::ISA = qw(Object);

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

sub flatten() {
	my($self) = shift;
	my($file) = shift;

	my(@arr) = $self->read($file);
	my($key) = undef;
	my($subkey) = undef;
	my(%res) = ();
	my(%key) = ();
	foreach ( @arr ) {
		if ( m/^\w+/ ) {
			$key = $_;
			$key =~ s/^\s+//;
			$subkey = "";
			next;
		}
		elsif ( m/(.*):$/ ) {
			$subkey = $1;
			$subkey =~ s/^\s+//;
			next;
		}
		elsif ( m/:/ ) {
			my($skey,$sval) = split(/:/,$_);
			s/\s+//;
			my($bepa) = $key . " " . $subkey . " " . $skey;
			$bepa =~ s/\s+/./g;
			$bepa = lc($bepa);
			if ( $res{$bepa} ) {
				my($i) = $key{$bepa};
				$i++;
				$key{$bepa}=$i;
				$bepa = $bepa . "." . $i;
			}
			$res{$bepa} = $sval;
		}
	}
	return(%res);
}

sub findkeys() {
	my($self) = shift;
	my($hp) = shift;
	my(@find) = @_;
	
	my(%keys) = ();
	my($key);
	foreach $key ( keys %$hp ) {
		my($value) = $hp->{$key};
		foreach ( @find ) {
			if ( $key =~ /$_/ ) {
				$keys{$key}=$value;
			}
		}
	}
	return(%keys);
}

1;