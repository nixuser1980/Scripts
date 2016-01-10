#!/bin/sh

#Manual Uninstall Script Copyright (2016) Damien Sticklen
#All called programs have the copyright of their respective owners
#This script is a manual uninstaller that uses system md5 hashing to determine duplicate files
#All you need is a test instance directory of the contents that is located in the target directory and it will find (and optionally delete) the matching files


if [ "$1" != "-u" -a "$1" != "-t" -o -z "$2" -o -z "$3" ]; then
	echo "Usage: $0 [-u|-t] <SOURCE FILES DIR> <ACTUAL INSTALL DIR>"	
	echo "-u Uninstall mode: run through the file comparison and uninstall files"
	echo  "-t Test mode: just run through the file comparison without deleting files"
	echo
	exit
fi

if [ ! -d "$2" ]; then
	echo  "No such directory $2"
	echo
	exit
fi

if [ ! -d "$3" ]; then
	echo  "No such directory $3"
	echo
	exit
fi

if [ "$2" = "$3" ]; then
	echo  "Source and search directories cannot be the same"
	echo
	exit
fi

PREFIX2=$(echo $2 | awk '{ print substr ($0, 0, 1) }')
PREFIX3=$(echo $3 | awk '{ print substr ($0, 0, 1) }')

if [ "$PREFIX2" != "$PREFIX3" ]; then
	echo "You may not mix relative with absolute paths" '\n'
	exit
fi

TRUNKPATH2=$(echo "$2" | sed s'/\/$//')
#echo "$TRUNKPATH2"
#sleep 60

echo  "Searching for installed files"
echo

DELCOUNT=0

for f in $(find $2 -type f ! -size 0 2>/dev/null); do
	HASH1=$(md5sum $f | awk '{ print $1 }')
	FILENAME1=$(basename $f)

	echo $f $HASH1

	for FILENAME2 in $(find "$3" -path "$TRUNKPATH2" -prune -o -type f ! -size 0 -name $FILENAME1 -print 2>/dev/null); do
		if [ -n "$FILENAME2" ]; then
			HASH2=$(md5sum $FILENAME2 | awk '{ print $1 }')

			if [ "$HASH2" = "$HASH1" ]; then
				if [ "$1" = "-u" ]; then
					rm -f $FILENAME2
					echo  "$FILENAME2 $HASH2 [MATCH UNINSTALLED]"
					DELCOUNT=$((DELCOUNT + 1))
				else
					echo  "$FILENAME2 $HASH2 [MATCH FOUND]"
				fi
			fi
		else 
			echo  "$f [NO MATCH FOUND]"	
		fi
	done
	echo
done

echo "Count of files uninstalled: "$DELCOUNT '\n' 
