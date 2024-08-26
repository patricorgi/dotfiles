#!/bin/bash

set -e

# check argument
if [ -z "$1" ]; then
	echo "Usage: $0 <target>"
	exit 1
fi

executable=$(which "$1")
shift

mkdir -p logs
if [[ $HOSTNAME == *"lxplus"* ]]; then
	submit_description="executable = $executable
arguments = $@
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
JobFlavour = espresso
request_cpus = 56
queue 1"
else
	submit_description="executable = $executable
arguments = $@
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
request_cpus = 56
queue 1"
fi
# Requirements = regexp(\"10.5.48.2\$\",Machine)
echo "$submit_description"
output=$(echo "$submit_description" | condor_submit 2>&1 | tee /dev/tty)
clusterID=$(echo "$output" | grep -oE '[0-9]{3,10}')

handle_sigint() {
	condor_rm $clusterID
	echo "Ctrl+C pressed. Removing job $clusterID..."
}
trap handle_sigint SIGINT

fileName=logs/$clusterID
counter=0
while [ ! -f "$fileName" ]; do
	((counter += 1))
	if [ $((counter % 500)) -eq 0 ]; then
		echo "Waiting for $fileName to be created..."
	fi
	sleep 0.1 # or less like 0.2
done
tail -f "$fileName" &
TAIL_PID=$!
while true; do
	jobStatus=$(condor_history -limit 1 -constraint "ClusterID==$clusterID" -af ExitCode)
	if [ -z "$jobStatus" ]; then
		sleep 5
		continue
	fi
	sleep 5
	break
done
kill $TAIL_PID
echo "condor_run results saved in $fileName"
exit $jobStatus
