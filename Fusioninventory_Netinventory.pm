package Fusioninventory_Netinventory;

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
		# <IFMTU>9216</IFMTU>
		#if ( m/\<(\w+)\>(.*)\</\w+\>/ ) {
		if ( m/\<(\w+)\>/ ) {
			my($key) = $1;
			if ( m/\<$key\>(.*)\<\/$key\>/ ) {
				print lc($key) . ": $1\n";
			}
		}
	}
	exit;
	return(%res);
}

sub getallkeys() {
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
