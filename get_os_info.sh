#!/usr/bin/env bash

target=$1

TRG=$(nmap -sL $target | grep "Nmap scan report" | awk '{print $NF}' | tr -d '()')

for i in $TRG
do
	nmap -p445 -Pn --script smb-os-discovery $i -oN $i-smb-os-discovery 

done