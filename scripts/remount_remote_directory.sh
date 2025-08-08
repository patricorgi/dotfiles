#!/bin/bash

if [ ! $# -gt 0 ]; then
	echo "No argument provided"
	exit 1
fi

remotePath="$1"
baseName=$(basename "$remotePath")
localPath="$HOME/$baseName"

# Check if localPath is already mounted
if mount | grep -q "on $localPath"; then
	echo "$localPath is already mounted. Unmounting..."
	umount $localPath
fi

sshfs -o defer_permissions,noappledouble,nolocalcaches,no_readahead,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,volname=$baseName $remotePath $localPath
