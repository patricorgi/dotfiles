#!/bin/bash

# check argument
if [ $# -lt 2 ]; then
	osascript -e 'display notification "Require <host> and <path>" with title "Yoink Remote File"'
	exit 1
fi
host=$1
filepath=$2
filebasename=$(basename $filepath)
localtmpfile=/tmp/$filebasename
scp $host:$filepath /tmp/$filebasename && open -a Yoink $localtmpfile
