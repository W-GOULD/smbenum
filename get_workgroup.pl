#!/usr/bin/perl

my $usage =<<USAGE;
example: perl get_workgroup.pl [ip or host]
USAGE

my $target   = $ARGV[0];

get_workgroup();

if ($target =~ /^([a-zA-Z0-9\._-]+)$/) {
	$target = $0;
} else {
	print "ERROR: Target hostname \"$target\" contains some illegal characters\n";
	exit 0;
}

sub get_workgroup {
	print "Enumerating Workgroup/Domain on $target\n";
	# Workgroup might already be known - e.g. from command line or from get_os_info()
	unless ($global_workgroup) {
		$global_workgroup = `nmblookup -A '$target'`; # Global var.  Erg!
		($global_workgroup) = $global_workgroup =~ /\s+(\S+)\s+<00> - <GROUP>/s;
		unless (defined($global_workgroup)) {
			print "[E] Can\'t find workgroup/domain\n";
			print "\n";
			return undef;
		}
		unless (defined($global_workgroup) and $global_workgroup =~ /^[A-Za-z0-9_\.-]+$/) {
			print "ERROR: Workgroup \"$global_workgroup\"contains some illegal characters\n";
			exit 1;
		}
	}
	print "[+] Got domain/workgroup name: $global_workgroup\n";
}
