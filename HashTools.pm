package HashTools;

use strict;
use Carp;
use Data::Dumper;
use XML::Parser;
use FindBin;
use lib $FindBin::Bin;

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
	if ( $key ) {
		return($key, $keys{$key} );
	}
	else {
		return(undef, undef);
	}
}

sub getfirstmatchingkeyvalue() {
	my($self) = shift;
	my($hp) = shift;
	my(@find) = @_;

	my($key,$value) = $self->getfirstmatchingkey($hp,@find);
	return($value, $key);
}

sub file2hash() {
	my($self) = shift;
	my($file) = shift;
	my($delimiter) = shift || ",";

	return(undef) unless ( $file );
	return(undef) unless ( -r $file );
	return(undef) unless ( open(IN,"<$file") );
	my($header) = scalar <IN>;
	unless ( $header ) {
		close(IN);
		return(undef);
	}
	chomp($header);

	my(@header) = ();
	foreach ( split(/$delimiter/,$header) ) {
		push(@header,$_);
	}

	my(@res) = ();
	my($line);
	foreach $line ( <IN> ) {
		chomp($line);
		#print "Got line [$line]\n";
		my(%line);
		my($head);
		my($value);
		my(@head) = @header;
		foreach $value ( split(/$delimiter/,$line) ) {
			$head = shift(@head);
			$line{$head}=$value;
		};
		push(@res,\%line);
	}
	close(IN);
	return(@res);
}

1;
