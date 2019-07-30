package Robot;

use strict;
use Carp;
use Data::Dumper;
use FindBin;
use lib $FindBin::Bin;

use HashTools;
use Dmidecode;
use Object;

$Robot::VERSION = '0.01';
@Robot::ISA = qw(Object HashTools);

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {};
        bless($self,$class);

	my($dir) = "/local/robot/curr";

        my(%hash) = ( dir => $dir, @_ );
        while ( my($key,$val) = each(%hash) ) {
                $self->set($key,$val);
        }

	$dir = $self->get("dir");
	if ( ! -d $dir ) {
		chdir($dir);
		#croak "$dir: $!";
	}
        return($self);
}

sub trim() {
	my($self) = shift;
	my($key) = shift;
	return(undef) unless ( defined($key) );
	$key =~ s/^\s+//;
	$key =~ s/\s+$//;
	return($key);
}

sub readfile() {
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

sub inventory() {
	my($self) = shift;
	my($target) = shift;
	my($odir) = $self->get("dir");
	my($dir) = $odir . "/$target";
	unless ( -d $dir ) {
		my(@dirs) = ( <$odir/$target*> );
		my($tdir) = shift(@dirs);
		if ( defined($tdir ) ) {
			$dir = $tdir;
		}
	}
	unless ( -d $dir ) {
		return(undef);
	}

	my(%inv) = ();

	my($model) = undef;
	my($type) = undef;
	my($manu) = undef;
	my($serial) = undef;
	my($completed) = 0;

	my($dmidecode) = new Dmidecode();
	my(%dmidecode) = $dmidecode->dmidecode2hash("$dir/dmidecode");
	my(@uname) = $self->readfile("$dir/uname_-a");
	my(@cosn) = $self->readfile("$dir/cosn");
	my(@ifconfig) = $self->readfile("$dir/ifconfig");
	
	#
	# model
	#
	if ( ! $model ) {
		# 
		# SPARC
		#
		if ( grep(/sparc/i,@uname) ) {
			if ( $uname[0] =~ /sparc\s+(.*)$/ ) {
				$model = $1;
				if ( $model =~ /SUNW/ ) {
					$manu = "Sun";
				}
			}
		}
	}
	unless ( $model ) {
		#
		# Intel/DMI
		#
		$model = $dmidecode->getfirstmatchingkey(\%dmidecode,"system.information.product.name") unless ( $model );
		$manu = $dmidecode->getfirstmatchingkey(\%dmidecode,"system.information.manufacturer") unless ( $manu );
	}


	#
	# Type
	#
	$type = "Physical Server";
	my(@eeprom) = $self->readfile("$dir/eeprom");
	if ( grep(/virtual-console/i,@eeprom) ) {
		$type = "Virtual Server";
	}
	elsif ( grep(/virtual/i,@uname) ) {
		$type = "Virtual Server";
	}
	elsif ( $model ) {
		if ( $model =~ /vmware/i ) {
			$type = "Virtual Server";
		}
	}
		

	
	#
	# Serial
	#

	$serial = $dmidecode->getfirstmatchingkey(\%dmidecode,"system.information.serial.number") unless ( $serial );

	if ( $serial ) {
		$serial =~ s/\s+//g;
	}

	#
	# Os
	#
	my($os) = undef;
	foreach ( @cosn ) {
		$os = $_;
	}

	#
	# Ip
	#
	my($ip) = undef;
	my($tip);
	foreach ( @ifconfig ) {
		next unless ( m/inet\s+(\d+\.\d+\.\d+\.\d+)\s/ );
		$tip = $1;
		unless ( $tip =~ /^127/ ) {
			$ip = $tip;
		}
	}

	$inv{manu}=$self->trim($manu) if ( $manu );
	$inv{type}=$self->trim($type) if ( $type );
	$inv{model}=$self->trim($model) if ( $model );
	$inv{serial}=$self->trim($serial) if ( $serial );
	$inv{os}=$self->trim($os) if ( $os );
	$inv{ip}=$self->trim($ip) if ( $ip );

	return(%inv);
}

1;
