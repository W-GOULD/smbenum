#!/usr/bin/perl

my $usage =<<USAGE;
example: perl get_workgroup.pl [ip or host]
USAGE
my $global_workgroup = undef;
my $global_username = '';
my $global_password = '';

my $target   = $ARGV[0];

get_os_info();

if ($target =~ /^([a-zA-Z0-9\._-]+)$/) {
	$target = $0;
} else {
	print "ERROR: Target hostname \"$target\" contains some illegal characters\n";
	exit 0;
}

sub get_os_info {
	print "OS information on $target\n";
	my $command = "smbclient -W '$global_workgroup' //'$target'/ipc\$ -U'$global_username'\%'$global_password' -c 'q' 2>&1";
	my $os_info = `$command`;
	chomp $os_info;
	if (defined($os_info)) {
		($os_info) = $os_info =~ /(Domain=[^\n]+)/s;
		print "[+] Got OS info for $target from smbclient: $os_info\n";
	}

	$command = "rpcclient -W '$global_workgroup' -U'$global_username'\%'$global_password' -c 'srvinfo' '$target' 2>&1";
	print "[V] Attempting to get OS info with command: $command\n" if $verbose;
	$os_info = `$command`;
	if (defined($os_info)) {
		if ($os_info =~ /error: NT_STATUS_ACCESS_DENIED/) {
			print "[E] Can't get OS info with srvinfo: NT_STATUS_ACCESS_DENIED\n";
		} else {
			print "[+] Got OS info for $target from srvinfo:\n$os_info";
		}
	}
}
