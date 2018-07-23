#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use File::Basename;
use Data::Dumper;
use Scalar::Util qw(tainted);

my $null_session_test = 0;


###############################################################################
# The following  mappings for nmblookup (nbtstat) status codes to human readable
# format is taken from nbtscan 1.5.1 "statusq.c".  This file in turn
# was derived from the Samba package which contains the following
# license:
#    Unix SMB/Netbios implementation
#    Version 1.9
#    Main SMB server routine
#    Copyright (C) Andrew Tridgell 1992-199
# 
#    This program is free software; you can redistribute it and/or modif
#    it under the terms of the GNU General Public License as published b
#    the Free Software Foundation; either version 2 of the License, o
#    (at your option) any later version
# 
#    This program is distributed in the hope that it will be useful
#    but WITHOUT ANY WARRANTY; without even the implied warranty o
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See th
#    GNU General Public License for more details
# 
#    You should have received a copy of the GNU General Public Licens
#    along with this program; if not, write to the Free Softwar
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA

my @nbt_info = (
["__MSBROWSE__", "01", 0, "Master Browser"],
["INet~Services", "1C", 0, "IIS"],
["IS~", "00", 1, "IIS"],
["", "00", 1, "Workstation Service"],
["", "01", 1, "Messenger Service"],
["", "03", 1, "Messenger Service"],
["", "06", 1, "RAS Server Service"],
["", "1F", 1, "NetDDE Service"],
["", "20", 1, "File Server Service"],
["", "21", 1, "RAS Client Service"],
["", "22", 1, "Microsoft Exchange Interchange(MSMail Connector)"],
["", "23", 1, "Microsoft Exchange Store"],
["", "24", 1, "Microsoft Exchange Directory"],
["", "30", 1, "Modem Sharing Server Service"],
["", "31", 1, "Modem Sharing Client Service"],
["", "43", 1, "SMS Clients Remote Control"],
["", "44", 1, "SMS Administrators Remote Control Tool"],
["", "45", 1, "SMS Clients Remote Chat"],
["", "46", 1, "SMS Clients Remote Transfer"],
["", "4C", 1, "DEC Pathworks TCPIP service on Windows NT"],
["", "52", 1, "DEC Pathworks TCPIP service on Windows NT"],
["", "87", 1, "Microsoft Exchange MTA"],
["", "6A", 1, "Microsoft Exchange IMC"],
["", "BE", 1, "Network Monitor Agent"],
["", "BF", 1, "Network Monitor Application"],
["", "03", 1, "Messenger Service"],
["", "00", 0, "Domain/Workgroup Name"],
["", "1B", 1, "Domain Master Browser"],
["", "1C", 0, "Domain Controllers"],
["", "1D", 1, "Master Browser"],
["", "1E", 0, "Browser Service Elections"],
["", "2B", 1, "Lotus Notes Server Service"],
["IRISMULTICAST", "2F", 0, "Lotus Notes"],
["IRISNAMESERVER", "33", 0, "Lotus Notes"],
['Forte_$ND800ZA', "20", 1, "DCA IrmaLan Gateway Server Service"]
);
####################### end of nbtscan-derrived code ############################

my $usage =<<USAGE;
example: perl get_nbtstat.pl [ip or host]
USAGE

$ENV{'PATH'} =~ /(.*)/;
$ENV{'PATH'} = $1;
$ENV{'PATH'} =~ s/^://;
$ENV{'PATH'} =~ s/:$//;
$ENV{'PATH'} =~ s/^\.://;
$ENV{'PATH'} =~ s/:\.//;

my $target   = $ARGV[0];

get_nbtstat();

sub nbt_to_human {
	my $nbt_in = shift; # multi-line
	my @nbt_in = split (/\n/, $nbt_in);
	my @nbt_out = ();
	foreach my $line (@nbt_in) {
		if ($line =~ /\s+(\S+)\s+<(..)>\s+-\s+?(<GROUP>)?\s+?[A-Z]/) {
			my $line_val = $1;
			my $line_code = uc $2;
			my $line_group = defined($3) ? 0 : 1; # opposite

			foreach my $info_aref (@nbt_info) {
				my ($pattern, $code, $group, $desc) = @$info_aref;
				# print "Matching: line=\"$line\", val=$line_val, code=$line_code, group=$line_group against pattern=$pattern, code=$code, group=$group, desc=$desc\n";
				if ($pattern) {
					if ($line_val =~ /$pattern/ and $line_code eq $code and $line_group eq $group) {
						push @nbt_out, "$line $desc";
						last;
					}
				} else {
					if ($line_code eq $code and $line_group eq $group) {
						push @nbt_out, "$line $desc";
						last;
					}
				}	
			}
		} else {
			push @nbt_out, $line;
		}
	}	
	return join "\n", @nbt_out;
}

if ($target =~ /^([a-zA-Z0-9\._-]+)$/) {
	$target = $0;
} else {
	print "ERROR: Target hostname \"$target\" contains some illegal characters\n";
	exit 0;
}

sub get_nbtstat {
	print "Nbtstat Information for $target\n";
	my $output = `nmblookup -A '$target' 2>&1`;
	$output = nbt_to_human($output);
	print "$output\n";
}
