#!/bin/bash

set -e

# parse optional condor resource arguments
request_cpus=""
while [[ $# -gt 0 ]]; do
	case "$1" in
		--request-cpus)
			if [[ -z "${2:-}" || "$2" == --* ]]; then
				echo "Error: --request-cpus requires a value" >&2
				exit 1
			fi
			request_cpus=$2
			shift 2
			;;
		--request-cpus=*)
			request_cpus=${1#*=}
			shift
			;;
		*)
			break
			;;
	esac
done

if [[ -n "$request_cpus" && ! "$request_cpus" =~ ^[1-9][0-9]*$ ]]; then
	echo "Error: --request-cpus must be a positive integer" >&2
	exit 1
fi

# check argument
if [ -z "${1:-}" ]; then
	echo "Usage: $0 [--request-cpus N] <target> [args...]"
	exit 1
fi

if [[ "$1" == */* ]]; then
	executable=$1
else
	executable=$(which "$1")
fi
shift

quote_condor_arg() {
	local s=$1
	s=${s//\'/\'\'} # inside a single-quoted HTCondor arg, ' becomes ''
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

extra_requirements=""
if [[ -n "${CONDOR_EXCLUDE_MACHINES:-}" ]]; then
	IFS=',' read -ra excluded_machines <<< "$CONDOR_EXCLUDE_MACHINES"
	for machine in "${excluded_machines[@]}"; do
		machine=${machine//[[:space:]]/}
		if [[ -n "$machine" ]]; then
			extra_requirements="$extra_requirements && TARGET.Machine != \"$machine\""
		fi
	done
fi

request_cpus_line=""
if [[ -n "$request_cpus" ]]; then
	request_cpus_line="request_cpus = $request_cpus
"
fi

requirements_expr=""
if [[ $HOSTNAME == "lhcb-login"* ]]; then
	requirements_expr="hasCVMFS && has_avx2$extra_requirements"
fi

machine_constraint=""
if [[ -n "$requirements_expr" ]]; then
	machine_constraint="$requirements_expr"
else
	machine_constraint="true"
fi
if [[ -n "$request_cpus" ]]; then
	machine_constraint="($machine_constraint) && Cpus >= $request_cpus"
fi

mkdir -p logs
if [[ $HOSTNAME == *"lxplus"* ]]; then
	submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
JobFlavour = espresso
${request_cpus_line:-request_cpus = 56
}queue 1"
elif [[ $HOSTNAME == "lhcb-login"* ]]; then
	submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
requirements = $requirements_expr
request_memory = 80000
${request_cpus_line}queue 1"
else
	submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
${request_cpus_line:-request_cpus = 56
}queue 1"
fi
# Requirements = regexp(\"10.5.48.2\$\",Machine)
echo "$submit_description"
if command -v condor_status >/dev/null 2>&1; then
	total_machines=$(condor_status -constraint "$machine_constraint" -af Machine 2>/dev/null | sort -u | wc -l)
	available_machines=$(condor_status -constraint "($machine_constraint) && State == \"Unclaimed\" && Activity == \"Idle\"" -af Machine 2>/dev/null | sort -u | wc -l)
	echo "Condor machines matching requirements: $total_machines total, $available_machines currently available"
fi
if tty -s; then
	output=$(echo "$submit_description" | condor_submit 2>&1 | tee /dev/tty)
else
	output=$(echo "$submit_description" | condor_submit 2>&1 | tee /dev/stdout)
fi
clusterID=$(echo "$output" | grep -oE '[0-9]{3,10}')

handle_sigint() {
	condor_rm $clusterID
	echo "Ctrl+C pressed. Removing job $clusterID..."
}
trap handle_sigint SIGINT

fileName=logs/$clusterID
touch "$fileName"
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
	jobQueueStatus=$(condor_q "$clusterID" -af JobStatus 2>/dev/null | tail -n1)
	if [[ "$jobQueueStatus" == "5" ]]; then
		holdReason=$(condor_q "$clusterID" -af HoldReason 2>/dev/null | tail -n1)
		echo "Job $clusterID is held: $holdReason"
		condor_rm "$clusterID" >/dev/null 2>&1 || true
		break
	fi

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
elif [[ "$jobQueueStatus" == "5" ]]; then
	exit 99
else
	echo "Warning: job exit code is not a number: $jobStatus"
	exit 1
fi
