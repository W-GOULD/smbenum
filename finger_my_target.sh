#!/bin/bash
WORDLIST="/usr/share/metasploit-framework/data/wordlists/unix_users.txt"

target=$1

TRG=$(nmap -sL $target | grep "Nmap scan report" | awk '{print $NF}' | tr -d '()')

for i in $TRG
do
	for username in $(cat $WORDLIST | sort -u| uniq)
		do output=$(finger -l $username@$i)
		if [[ $output == *"Directory"* ]]
			then
				echo "Found user: $username"
		fi
		done

echo "Finished!"