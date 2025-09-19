#!/bin/bash

if [ ! $# -gt 0 ]; then
	echo "No argument provided"
	exit 1
fi

remotePath="$1"
baseName=$(basename "$remotePath")
localPath="$HOME/SSHFS/$baseName"
mkdir -p $localPath

# Check if localPath is already mounted and accessible
if mount | grep -q "on $localPath"; then
	echo "$localPath is mounted."
	umount "$localPath"
fi

while true; do
    /usr/local/bin/sshfs -o defer_permissions,noappledouble,nolocalcaches,no_readahead,ServerAliveInterval=5,ServerAliveCountMax=2,volname=$baseName $remotePath $localPath
	status=$?
	if [ $status -eq 0 ]; then
        break
    fi
	echo "Connection failed. Reconnecting..."
	sleep 2
done
