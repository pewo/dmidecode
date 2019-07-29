package Vlan;

use strict;
use Carp;
use Data::Dumper;
use FindBin;
use NetAddr::IP;
use lib $FindBin::Bin;
use Object;
use HashTools;

my($vlandb) = "vlan.csv";
my($IFS) = ";";

$Vlan::VERSION = '0.01';
@Vlan::ISA = qw(Object HashTools);

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {};
        bless($self,$class);

        my(%hash) = ( db => $vlandb, @_ );
        while ( my($key,$val) = each(%hash) ) {
                $self->set($key,$val);
        }

	$self->set("initiated",0);
	$self->_initiate();

        return($self);
}

#
# loads the vlan database to memory
# It is available from the content method
#
sub _initiate() {
	my($self) = shift;
	my($db) = shift || $self->get("db");
	my($delimiter) = shift || $IFS;
	my(@arr) = $self->file2hash($db,$IFS);
	my($rec);
	my(@res) = ();
	foreach $rec ( @arr ) {
		my($network) = $rec->{network};
		#print "network: $network\n";
		my($addr) = NetAddr::IP->new($network);
		if ( $addr ) {
			$rec->{addr}=$addr;
		}
		push(@res,$rec);
	}
	$self->set("content",\@res);
	$self->set("initiated",1);
}

#
# Return all vlan id as an array
#
sub vlanid() {
	my($self) = shift;
	my($ap) = $self->get("content");
	my($rec);
	my(@res) = ();
	foreach $rec ( @$ap ) {
		#print "ref: " . ref($rec) . "\n";
		my($id) = $rec->{id};
		push(@res,$id);
	}
	return(@res);
}

#
# Return the content of the vlan database, as an array of hashes
#
sub content() {
	my($self) = shift;
	my($ap) = $self->get("content");
	return(@$ap);
}
	
#
# Try to find which vlan that can hold the ip address
# Returns the vlan hash if it's found
#
sub ip() {
	my($self) = shift;
	my($ip) = shift;
	return(undef) unless ( defined($ip) );
	my($find) = NetAddr::IP->new($ip);
	return(undef) unless ( defined($find) );

	my($ap) = $self->get("content");
	my($rec);
	foreach $rec ( @$ap ) {
		my($addr) = $rec->{addr};
		next unless ( $addr );
		if ( $find->within($addr) ) {
			return($rec);
		}
	}
	return(undef);
}

1;
