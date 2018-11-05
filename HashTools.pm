package HashTools;

use strict;
use Carp;
use Data::Dumper;
use XML::Parser;
use lib ".";
use Object;

$HashTools::VERSION = '0.01';
@HashTools::ISA = qw(Object);

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

sub getallmatchingkeys() {
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
				$keys{$key}=$value;
			}
		}
	}
	return(%keys);
}

sub getallmatchingkeyvalues() {
	my($self) = shift;
	my($hp) = shift;
	my(@find) = @_;
	
	my($res) = "";
	my(@res) = ();
	my(%keys) = $self->getallmatchingkeys($hp,@find);
	my($key);
	foreach $key ( keys %keys ) {
		my($value) = $keys{$key};
		push(@res,$value);
	}

	if ( wantarray ) {
		return(@res);
	}
	else {
		return(join(" ",@res));
	}
}

sub getfirstmatchingkey() {
	my($self) = shift;
	my($hp) = shift;
	my(@find) = @_;
	
	my($res) = "";
	my(%keys) = $self->getallmatchingkeys($hp,@find);
	my(@res) = sort keys %keys;
	my($key) = shift(@res);
	return($key, $keys{$key} );
}

sub getfirstmatchingkeyvalue() {
	my($self) = shift;
	my($hp) = shift;
	my(@find) = @_;

	my($key,$value) = $self->getfirstmatchingkey($hp,@find);
	return($value, $key);
}

1;
