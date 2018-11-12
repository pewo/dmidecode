package Ansible;

use strict;
use Data::Dumper;
use JSON;
use Carp;

use lib ".";
use Object;
use HashTools;
our @ISA = qw(Object HashTools);

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {};
        bless($self,$class);

	my($dir) = "/local/ansible/cache/ansible_fact_cache/";

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


sub json2flathash() {
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

sub inventory() {
	my($self) = shift;
	my($target) = shift;
	my($dir) = $self->get("dir");

        my($factsf) = <$dir/$target*>;
	print "factsf: $factsf\n";
	my(%keys) = $self->json2flathash($factsf);

	my(%inv);
	#foreach ( sort keys %keys ) {
		#print "$_\t$keys{$_}\n";
	#}
	

	#
	# Hostname
	#
	my($hostname) = $self->getfirstmatchingkeyvalue(\%keys,"ansible_hostname");
	$inv{hostname}=$hostname;

	#
	# Ip
	#
	my($ip) = undef;
	($ip) = $self->getfirstmatchingkeyvalue(\%keys,"ansible_default_ipv4.address") unless ( $ip );
	$inv{ip}=$ip;

	#
	# os/version
	#
	my($os) = undef;
	($os) = $self->getfirstmatchingkeyvalue(\%keys,"ansible_distribution") unless ( $os );

	my($version) = undef;
	($version) = $self->getfirstmatchingkeyvalue(\%keys,"ansible_distribution_version") unless ( $version );

	$inv{os}="$os $version";

	#
	# domain
	#
	my($domain) = undef;
	$domain = $self->getallmatchingkeyvalues(\%keys,"ansible_domain","ansible_dns.search","ansible_dns.domain","ansible_fqdn");
	if ( $domain ) {
		if ( $domain =~ /corp/ ) {
			$domain = "corp";
		}
		elsif ( $domain =~ /pdom/ ) {
			$domain = "pdom";
		}
		elsif ( $domain =~ /ericsson/ ) {
			$domain = "fhi";
		}
		else {
			$domain = "unknown";
		}
	}
	$inv{domain}=$domain;

	# Maybe include: ansible_virtualization_type

	#
	# MAC
	#
	my($mac) = undef;
	($mac) = $self->getfirstmatchingkeyvalue(\%keys,"ansible_default_ipv4.macaddress") unless ( $mac );
	$inv{mac}=$mac;

	return(%inv);
}
1;
