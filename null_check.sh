#!/bin/bash
target=$1

TRG=$(nmap -sL $target | grep "Nmap scan report" | awk '{print $NF}' | tr -d '()')

for i in $TRG
do
	output=$(bash -c "echo 'srvinfo' | rpcclient $i -U%")
	echo $output
done
