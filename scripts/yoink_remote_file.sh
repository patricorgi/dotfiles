#!/bin/bash

# check argument
if [ $# -lt 2 ]; then
	osascript -e 'display notification "Require <host> and <path>" with title "Yoink Remote File"'
	exit 1
fi
host=$1
for filepath in "${@:2}"; do
	filebasename=$(basename $filepath)
	localtmpfile=/tmp/$filebasename
	echo scp $host:$filepath /tmp/$filebasename && open -a Yoink $localtmpfile
	scp $host:$filepath /tmp/$filebasename && open -a Yoink $localtmpfile
done
