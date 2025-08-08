#!/bin/bash

set -e

mkdir -p logs
output=$(condor_submit "$1" 2>&1 | tee /dev/tty)
clusterID=$(echo "$output" | grep -oE '[0-9]{6}')
fileName=logs/$clusterID
counter=0
while [ ! -f "$fileName" ]; do
	((counter+=1))
	if [ $((counter % 100)) -eq 0 ]; then
			echo "Waiting for $fileName to be created..."
  fi
	sleep 0.2 # or less like 0.2
done
tail -f "$fileName" &
TAIL_PID=$!
while true; do
	jobStatus=$(condor_history -limit 1 -constraint "ClusterID==$clusterID" -af ExitCode)
	if [ -z "$jobStatus" ]; then sleep 5; continue; fi
	sleep 5
	break
done
kill $TAIL_PID
exit $jobStatus

