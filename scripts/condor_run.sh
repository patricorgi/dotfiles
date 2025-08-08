#!/bin/bash

set -e

# check argument
if [ -z "$1" ]; then
	echo "Usage: $0 <target>"
	exit 1
fi

executable=$(which "$1")
shift

quote_condor_arg() {
    local s=$1
    s=${s//\'/\'\'}   # inside a single-quoted HTCondor arg, ' becomes ''
    printf "'%s'" "$s"
}

args=""
for arg in "$@"; do
    quoted=$(quote_condor_arg "$arg")
    if [ -z "$args" ]; then
        args=$quoted
    else
        args="$args $quoted"
    fi
done

mkdir -p logs
if [[ $HOSTNAME == *"lxplus"* ]]; then
	submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
JobFlavour = espresso
request_cpus = 56
queue 1"
elif [[ $HOSTNAME == "lhcb-login"* ]]; then
	submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
requirements = hasCVMFS && has_avx2
request_memory = 20000
queue 1"
else
	submit_description="executable = $executable
arguments = \"$args\"
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
	jobStatus=$(condor_history -limit 1 -constraint "ClusterID==$clusterID" -af ExitCode 2>/dev/null | tail -n1)

	if [ -z "$jobStatus" ]; then
		sleep 5
		continue
	fi

	sleep 5
	break
done

kill $TAIL_PID

echo "condor_run results saved in $fileName"

if [[ "$jobStatus" =~ ^[0-9]+$ ]]; then
	exit "$jobStatus"
else
	echo "Warning: job exit code is not a number: $jobStatus"
	exit 1
fi
