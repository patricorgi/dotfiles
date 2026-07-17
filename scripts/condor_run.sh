#!/bin/bash

set -e

max_attempts=${MAX_ATTEMPTS:-1}
retry_delay_seconds=${RETRY_DELAY_SECONDS:-1}
history_grace_polls=${CONDOR_HISTORY_GRACE_POLLS:-12}
bad_nodes_file=${CONDOR_BAD_NODES_FILE:-logs/bad_condor_nodes.txt}
failure_pattern='cvmfs|/cvmfs|transport endpoint is not connected|could not open image'

if ! [[ ${max_attempts} =~ ^[1-9][0-9]*$ ]]; then
	echo "Error: MAX_ATTEMPTS must be a positive integer" >&2
	exit 1
fi
if ! [[ ${retry_delay_seconds} =~ ^[0-9]+$ ]]; then
	echo "Error: RETRY_DELAY_SECONDS must be a non-negative integer" >&2
	exit 1
fi
if ! [[ ${history_grace_polls} =~ ^[1-9][0-9]*$ ]]; then
	echo "Error: CONDOR_HISTORY_GRACE_POLLS must be a positive integer" >&2
	exit 1
fi

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

request_cpus_line=""
if [[ -n "$request_cpus" ]]; then
	request_cpus_line="request_cpus = $request_cpus
"
fi

clusterID=""
TAIL_PID=""

cleanup_tail() {
	if [[ -n "$TAIL_PID" ]]; then
		kill "$TAIL_PID" 2>/dev/null || true
		wait "$TAIL_PID" 2>/dev/null || true
		TAIL_PID=""
	fi
}

handle_signal() {
	local signal=$1
	local exit_code=143

	cleanup_tail
	if [[ -n "${clusterID:-}" ]]; then
		condor_rm "$clusterID" >/dev/null 2>&1 || true
		echo "Signal $signal received. Removing job $clusterID..." >&2
	fi
	[[ "$signal" == "INT" ]] && exit_code=130
	exit "$exit_code"
}
trap 'handle_signal INT' SIGINT
trap 'handle_signal TERM' SIGTERM
trap cleanup_tail EXIT

blacklist_condor_node_name() {
	local node=$1

	[[ -z ${node} ]] && return 0
	node=${node#*@}
	if ! [[ ${node} =~ ^[A-Za-z0-9._-]+$ ]]; then
		echo "Ignoring invalid Condor node name: $node" >&2
		return 0
	fi

	touch "$bad_nodes_file"
	if grep -Fxq "$node" "$bad_nodes_file"; then
		echo "Condor node $node is already blacklisted." >&2
	else
		printf '%s\n' "$node" >>"$bad_nodes_file"
		echo "Blacklisted Condor node $node." >&2
	fi
}

condor_exclude_requirements() {
	local machine
	local extra_requirements=""
	local excluded_machines=()

	if [[ -n "${CONDOR_EXCLUDE_MACHINES:-}" ]]; then
		IFS=',' read -ra excluded_machines <<< "$CONDOR_EXCLUDE_MACHINES"
		for machine in "${excluded_machines[@]}"; do
			machine=${machine//[[:space:]]/}
			[[ -n "$machine" ]] && extra_requirements="$extra_requirements && TARGET.Machine != \"$machine\""
		done
	fi
	if [[ -f "$bad_nodes_file" ]]; then
		while IFS= read -r machine; do
			[[ -z "$machine" ]] && continue
			if [[ "$machine" =~ ^[A-Za-z0-9._-]+$ ]]; then
				extra_requirements="$extra_requirements && TARGET.Machine != \"$machine\""
			else
				echo "Ignoring invalid blacklisted node entry: $machine" >&2
			fi
		done <"$bad_nodes_file"
	fi

	printf '%s\n' "$extra_requirements"
}

blacklist_condor_node_for_cluster() {
	local cluster_id=$1
	local node=""
	local remote_host=""

	[[ -n "$cluster_id" ]] || return 0
	remote_host=$(condor_history -limit 1 -constraint "ClusterID==$cluster_id" -af LastRemoteHost 2>/dev/null | tail -n1 || true)
	if [[ -n "$remote_host" ]]; then
		node=${remote_host#*@}
	fi
	if [[ -z "$node" || "$node" == "undefined" ]]; then
		node=$(sed -n "/Cluster $cluster_id/,/Job terminated/p" logs/condor.log 2>/dev/null | sed -n 's/.*alias=\([^&>]*\).*/\1/p' | tail -n1)
	fi

	if [[ -n "$node" && "$node" != "undefined" ]]; then
		blacklist_condor_node_name "$node"
	else
		echo "Could not identify execute node for cluster $cluster_id; not updating blacklist." >&2
	fi
}

run_one_attempt() {
	local extra_requirements
	local requirements_expr=""
	local requirements_line=""
	local machine_constraint
	local submit_description
	local output
	local holdReason
	local jobQueueStatus=""
	local jobStatus=""
	local missing_history_polls=0

	extra_requirements=$(condor_exclude_requirements)
	if [[ $HOSTNAME == "lhcb-login"* ]]; then
		requirements_expr="hasCVMFS && has_avx2$extra_requirements"
	elif [[ -n "$extra_requirements" ]]; then
		requirements_expr="true$extra_requirements"
	fi
	if [[ -n "$requirements_expr" ]]; then
		requirements_line="requirements = $requirements_expr
"
	fi

	if [[ -n "$requirements_expr" ]]; then
		machine_constraint="$requirements_expr"
	else
		machine_constraint="true"
	fi
	if [[ -n "$request_cpus" ]]; then
		machine_constraint="($machine_constraint) && Cpus >= $request_cpus"
	fi

	if [[ $HOSTNAME == *"lxplus"* ]]; then
		submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
${requirements_line}JobFlavour = espresso
${request_cpus_line:-request_cpus = 56
}queue 1"
	elif [[ $HOSTNAME == "lhcb-login"* ]]; then
		submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
${requirements_line}request_memory = 80000
${request_cpus_line}queue 1"
	else
		submit_description="executable = $executable
arguments = \"$args\"
getEnv = True
log = logs/condor.log
output = logs/\$(ClusterID)
error = logs/\$(ClusterID)
${requirements_line}${request_cpus_line:-request_cpus = 56
}queue 1"
	fi

	# Requirements = regexp("10.5.48.2$",Machine)
	echo "$submit_description"
	if command -v condor_status >/dev/null 2>&1; then
		total_machines=$(condor_status -constraint "$machine_constraint" -af Machine 2>/dev/null | sort -u | wc -l)
		available_machines=$(condor_status -constraint "($machine_constraint) && State == \"Unclaimed\" && Activity == \"Idle\"" -af Machine 2>/dev/null | sort -u | wc -l)
		echo "Condor machines matching requirements: $total_machines total, $available_machines currently available"
	fi
	if tty -s; then
		output=$(printf '%s\n' "$submit_description" | condor_submit 2>&1 | tee /dev/tty)
	else
		output=$(printf '%s\n' "$submit_description" | condor_submit 2>&1)
		printf '%s\n' "$output"
	fi
	clusterID=$(printf '%s\n' "$output" | sed -n 's/.*cluster \([0-9][0-9]*\).*/\1/p' | tail -n1)
	if ! [[ "$clusterID" =~ ^[0-9]+$ ]]; then
		echo "Warning: could not determine Condor cluster ID"
		clusterID=""
		return 1
	fi

	fileName=logs/$clusterID
	touch "$fileName"
	tail -f -- "$fileName" &
	TAIL_PID=$!
	while true; do
		jobQueueStatus=$(condor_q "$clusterID" -af JobStatus 2>/dev/null | tail -n1 || true)
		if [[ "$jobQueueStatus" == "5" ]]; then
			holdReason=$(condor_q "$clusterID" -af HoldReason 2>/dev/null | tail -n1)
			echo "Job $clusterID is held: $holdReason"
			condor_rm "$clusterID" >/dev/null 2>&1 || true
			cleanup_tail
			return 99
		fi

		jobStatus=$(condor_history -limit 1 -constraint "ClusterID==$clusterID" -af ExitCode 2>/dev/null | tail -n1 || true)
		if [[ "$jobStatus" =~ ^[0-9]+$ ]]; then
			break
		fi

		if [[ -z "$jobQueueStatus" ]]; then
			((missing_history_polls += 1))
			if ((missing_history_polls >= history_grace_polls)); then
				echo "Job $clusterID is no longer in the queue, but no numeric exit code appeared in history after $history_grace_polls checks." >&2
				cleanup_tail
				return 1
			fi
		else
			missing_history_polls=0
		fi
		sleep 5
	done

	cleanup_tail

	echo "condor_run results saved in $fileName"

	if [[ "$jobStatus" =~ ^[0-9]+$ ]]; then
		return "$jobStatus"
	fi
	echo "Warning: job exit code is not a number: $jobStatus"
	return 1
}

mkdir -p logs
attempt=1
while ((attempt <= max_attempts)); do
	if ((max_attempts > 1)); then
		echo "Running Condor attempt $attempt/$max_attempts with bad_nodes_file=$bad_nodes_file"
	fi
	if run_one_attempt; then
		exit 0
	else
		status=$?
	fi

	if [[ -n "${fileName:-}" && -f "$fileName" ]] && grep -qiE "$failure_pattern" "$fileName"; then
		blacklist_condor_node_for_cluster "$clusterID"
		if ((attempt < max_attempts)); then
			echo "Retrying Condor job after failed attempt $attempt/$max_attempts in $retry_delay_seconds seconds."
			sleep "$retry_delay_seconds"
			((attempt += 1))
			continue
		fi
	fi

	exit "$status"
done

exit "$status"
