#!/usr/bin/env bash

target=$1

TRG=$(nmap -sL $target | grep "Nmap scan report" | awk '{print $NF}' | tr -d '()')

for i in $TRG
do
	nmap -p445 -Pn --script smb-os-discovery $i -oN $i-smb-os-discovery 
	OS=$(cat $i-smb-os-discovery | grep 'OS:')
	Computername=$(cat $i-smb-os-discovery | grep 'Computer name:')
	NetBIOS=$(cat $i-smb-os-discovery | grep 'NetBIOS computer name:')
	Workgroup=$(cat $i-smb-os-discovery | grep 'Workgroup:')
	Domain=$(cat $i-smb-os-discovery | grep 'Domain name:')
	FQDN=$(cat $i-smb-os-discovery | grep 'FQDN:')
	echo $OS $Computername $NetBIOS $Workgroup $Domain $FQDN | tee 

done