#!/usr/bin/env bash
# Monitor submitted HTCondor jobs for their first 20 minutes, then hand them
# to a durable user-systemd notifier.  Pass --retry-submit to permit retries.

set -u -o pipefail

# Required notification recipient, supplied by the caller's environment.
recipient=${EMAIL:-}
interval=60
early_minutes=5
duration_minutes=20
retry_submit=
state_dir=
notify_mode=0

# Literal, case-insensitive fragments that identify retryable Condor worker or
# scheduler failures. Add one quoted string per new confirmed infrastructure
# issue; do not add normal application, build, or analysis errors here.
known_condor_issue_patterns=(
	"transport endpoint is not connected"
	"could not open image"
	"worker-side stdout sandbox"
	"worker-side stderr sandbox"
	"Failed to execute starter"
	"Failed to execute apptainer"
	"CVMFS unavailable"
	"CVMFS is not readable"
	"/cvmfs/lhcb.cern.ch/lib/LbEnv is not readable"
	"CVMFS study preflight failed:"
	"libcatboostmodel.so: cannot read file data: Input/output error"
	"lb-conda is not available"
)

usage() {
	cat <<'EOF'
Usage: condor_health_watch.sh [options] CLUSTER[.PROCESS] ...

Monitor one or more already-submitted HTCondor jobs every minute.  A job that
starts within five minutes is watched through minute 20; then a user-systemd
service checks it every 10 minutes and emails completion or failure.

Options:
  --early-minutes N   Minutes in which a job must start (default: 5).
  --duration-minutes N
                       Total foreground monitoring duration in minutes
                       (default: 20; must be at least --early-minutes).
  --retry-submit FILE  Submit description to reuse after a confirmed worker/
                       scheduler failure. Its Requirements line is retained
                       and extended to exclude the failing execute node.
  --state-dir DIR      Durable notifier state directory (default:
                       ~/.local/state/condor-health-watch/<timestamp>-<pid>)
  --notify-state DIR   Internal: run the durable notification worker.
  -h, --help           Show this help.

Environment:
  EMAIL                Required notification recipient.

Examples:
  condor_health_watch.sh 12345 12346.0
  condor_health_watch.sh --early-minutes 3 --duration-minutes 15 12345
  condor_health_watch.sh --retry-submit jobs/fit.sub 12345
EOF
}

die() { printf 'Error: %s\n' "$*" >&2; exit 2; }

while (($#)); do
	case "$1" in
		--early-minutes) early_minutes=${2:?--early-minutes requires an integer}; shift 2 ;;
		--duration-minutes) duration_minutes=${2:?--duration-minutes requires an integer}; shift 2 ;;
		--retry-submit) retry_submit=${2:?--retry-submit requires a file}; shift 2 ;;
		--state-dir) state_dir=${2:?--state-dir requires a directory}; shift 2 ;;
		--notify-state) notify_mode=1; state_dir=${2:?--notify-state requires a directory}; shift 2 ;;
		-h|--help) usage; exit 0 ;;
		--*) die "unknown option: $1" ;;
		*) break ;;
	esac
done

[[ $early_minutes =~ ^[1-9][0-9]*$ ]] || die "--early-minutes must be a positive integer"
[[ $duration_minutes =~ ^[1-9][0-9]*$ ]] || die "--duration-minutes must be a positive integer"
((duration_minutes >= early_minutes)) || die "--duration-minutes must be at least --early-minutes"
[[ -n $recipient ]] || die "EMAIL must name the notification recipient"
early_window=$((early_minutes * 60))
monitor_window=$((duration_minutes * 60))

mail_notice() {
	local subject=$1 body=$2
	printf '%s\n' "$body" | mail -s "$subject" "$recipient"
}

job_history() {
	local job=$1
	condor_history -limit 1 -constraint "ClusterId == ${job%%.*}$([[ $job == *.* ]] && printf ' && ProcId == %s' "${job#*.}")" \
		-af ClusterId ProcId JobStatus QDate ExitCode LastRemoteHost Out Err HoldReason 2>/dev/null | tail -n 1
}

job_queue_status() {
	local job=$1
	condor_q "$job" -af JobStatus 2>/dev/null | tail -n 1
}

job_label() {
	local job=$1 history
	history=$(job_history "$job")
	if [[ -n $history ]]; then
		read -r cluster proc _ <<<"$history"
		printf '%s.%s\n' "$cluster" "$proc"
	else
		printf '%s\n' "$job"
	fi
}

log_excerpt() {
	local job=$1 history out err
	history=$(job_history "$job")
	read -r _ _ _ _ _ _ out err _ <<<"$history"
	for path in "$out" "$err" "logs/${job%%.*}"; do
		[[ -n $path && -r $path ]] || continue
		printf '\n--- %s (last 80 lines) ---\n' "$path"
		tail -n 80 -- "$path"
		done
}

is_known_infrastructure_failure() {
	local job=$1 text pattern
	text=$(log_excerpt "$job" 2>&1 || true)
	for pattern in "${known_condor_issue_patterns[@]}"; do
		if [[ ${text,,} == *"${pattern,,}"* ]]; then
			return 0
		fi
	done
	return 1
}

last_remote_host() {
	local job=$1 history host
	history=$(job_history "$job")
	read -r _ _ _ _ _ host _ <<<"$history"
	host=${host#*@}
	[[ $host =~ ^[A-Za-z0-9._-]+$ ]] && printf '%s\n' "$host"
}

retry_with_blacklist() {
	local job=$1 node=$2 existing requirements tmp_submit output new_cluster
	[[ -n $retry_submit ]] || return 1
	[[ -r $retry_submit ]] || die "retry submit file is not readable: $retry_submit"
	existing=$(awk 'BEGIN { IGNORECASE=1 } /^[[:space:]]*requirements[[:space:]]*=/ { sub(/^[^=]*=[[:space:]]*/, ""); print; exit }' "$retry_submit")
	requirements="(TARGET.Machine != \"$node\")"
	[[ -n $existing ]] && requirements="($existing) && $requirements"
	tmp_submit=$(mktemp "${state_dir}/retry.XXXXXX.sub")
	awk -v requirements="$requirements" '
		BEGIN { IGNORECASE=1 }
		/^[[:space:]]*requirements[[:space:]]*=/ { next }
		/^[[:space:]]*queue([[:space:]]|$)/ && !inserted {
			print "requirements = " requirements
			inserted = 1
		}
		{ print }
		END { if (!inserted) exit 1 }
	' "$retry_submit" >"$tmp_submit" || die "retry submit file has no queue statement: $retry_submit"
	output=$(condor_submit "$tmp_submit" 2>&1) || {
		printf '%s\n' "$output" >&2
		return 1
	}
	new_cluster=$(printf '%s\n' "$output" | sed -n 's/.*cluster \([0-9][0-9]*\).*/\1/p' | tail -n 1)
	[[ $new_cluster =~ ^[0-9]+$ ]] || return 1
	grep -Fxq "$node" "$state_dir/bad_nodes.txt" 2>/dev/null || printf '%s\n' "$node" >>"$state_dir/bad_nodes.txt"
	printf '%s\n' "$new_cluster"
}

notify_worker() {
	local job status history exit_code
	while :; do
		job=$(<"$state_dir/job")
		status=$(job_queue_status "$job")
		if [[ -n $status ]]; then
			sleep 600
			continue
		fi
		history=$(job_history "$job")
		if [[ -z $history ]]; then
			sleep 600
			continue
		fi
		read -r _ _ _ _ exit_code _ <<<"$history"
		if [[ $exit_code == 0 ]]; then
			mail_notice "HTCondor job $job completed" "HTCondor job $job completed successfully.\nState: $state_dir"
		else
			mail_notice "HTCondor job $job failed" "HTCondor job $job left the queue with exit code ${exit_code:-unknown}.\nState: $state_dir\n$(log_excerpt "$job")"
		fi
		return
	done
}

if ((notify_mode)); then
	[[ -d $state_dir && -f $state_dir/job ]] || die "invalid notification state: $state_dir"
	notify_worker
	exit 0
fi

(($#)) || { usage >&2; exit 2; }
command -v condor_q >/dev/null || die "condor_q is unavailable"
command -v condor_history >/dev/null || die "condor_history is unavailable"
command -v mail >/dev/null || die "mail is unavailable"
if [[ -z $state_dir ]]; then
	state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/condor-health-watch/$(date +%Y%m%d-%H%M%S)-$$"
fi
mkdir -p "$state_dir"
printf '%s\n' "$*" >"$state_dir/original_jobs"

declare -A active ever_running started_at
for job in "$@"; do
	[[ $job =~ ^[0-9]+(\.[0-9]+)?$ ]] || die "invalid job ID: $job"
	active["$job"]=1
	started_at["$job"]=$(date +%s)
	done

while ((${#active[@]})); do
	now=$(date +%s)
	for job in "${!active[@]}"; do
		elapsed=$((now - started_at[$job]))
		status=$(job_queue_status "$job")
		if [[ $status == 2 && $elapsed -le $early_window ]]; then ever_running["$job"]=1; fi
		if [[ -n $status ]]; then
			printf '[%(%F %T)T] %s: queue status %s\n' -1 "$job" "$status"
			if ((elapsed >= early_window)) && [[ -z ${ever_running[$job]:-} ]]; then
				printf '%s did not start within five minutes; ending foreground monitoring for it.\n' "$job"
				unset 'active[$job]'
			fi
			continue
		fi
		history=$(job_history "$job")
		if [[ -z $history ]]; then
			printf '[%(%F %T)T] %s: absent from queue and history\n' -1 "$job"
			continue
		fi
		read -r _ _ _ submitted_epoch exit_code _ <<<"$history"
		if [[ $submitted_epoch =~ ^[0-9]+$ ]] && ((now - submitted_epoch <= early_window)) && [[ ${exit_code:-1} != 0 ]]; then
			if is_known_infrastructure_failure "$job" && node=$(last_remote_host "$job") && [[ -n $retry_submit ]]; then
				printf '[%(%F %T)T] %s: infrastructure failure on %s; retrying\n' -1 "$job" "$node"
				if new_job=$(retry_with_blacklist "$job" "$node"); then
					unset 'active[$job]'
					unset 'started_at[$job]'
					active["$new_job"]=1
					started_at["$new_job"]=$(date +%s)
					continue
				fi
			fi
			mail_notice "HTCondor job $job failed during health check" "HTCondor job $job failed within five minutes with exit code ${exit_code:-unknown}.\n$(log_excerpt "$job")"
		fi
		unset 'active[$job]'
	done
	done_monitoring=0
	for job in "${!active[@]}"; do
		elapsed=$((now - started_at[$job]))
		if ((elapsed < monitor_window)) && { ((elapsed < early_window)) || [[ -n ${ever_running[$job]:-} ]]; }; then
			done_monitoring=1
			break
		fi
	done
	if ((done_monitoring == 0)); then
		printf 'No monitored job started within five minutes; ending foreground monitoring.\n'
		break
	fi
	sleep "$interval"
done

for job in "${!active[@]}"; do
	job_state_dir="$state_dir/${job//./-}"
	mkdir -p "$job_state_dir"
	printf '%s\n' "$job" >"$job_state_dir/job"
	unit="condor-health-notify-${job//./-}-$(basename "$state_dir")"
	if systemd-run --user --unit="$unit" --collect --quiet "$0" --notify-state "$job_state_dir"; then
		printf 'Notification service %s will check %s every 10 minutes. State: %s\n' "$unit" "$job" "$job_state_dir"
	else
		printf 'Could not start user-systemd notification service for %s.\n' "$job" >&2
	fi
	done
