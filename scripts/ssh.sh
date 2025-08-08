#!/bin/bash

unmount() {
	osascript -e "display notification \"Unmounting $1\" with title \"kitty\""
	diskutil unmount force "$1" || echo 'Failed to unmount.'
}

trap unmount EXIT

hostname="$1"
mountpoint="$2"
while true; do
	/opt/homebrew/bin/kitty +kitten ssh $hostname -t 'bash -i -c tm'
	status=$?
	if [ $status -eq 0 ]; then
		echo "Detached from tmux, exiting loop."
		break
	fi
	echo "Connection lost. Reconnecting in 2 seconds..."
	sleep 2
done
