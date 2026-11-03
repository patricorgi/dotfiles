#!/usr/bin/env bash
# Compact, cached HTCondor status for tmux.  condor_q defaults to this user.

set -u

cache_root=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}
cache_dir="${cache_root%/}/tmux-condor-status-$UID"
cache_file="$cache_dir/status"
lock_dir="$cache_dir/lock"
cache_ttl=30
lock_ttl=120

command -v condor_q >/dev/null 2>&1 || exit 0
mkdir -p "$cache_dir" 2>/dev/null || exit 0

now=$(date +%s)
stale=1
if [[ -f $cache_file ]]; then

	cache_mtime=$(stat -c %Y -- "$cache_file" 2>/dev/null || printf '0')
	if (( now - cache_mtime < cache_ttl )); then
		stale=0
	fi
fi

if [[ -d $lock_dir ]]; then
	lock_mtime=$(stat -c %Y -- "$lock_dir" 2>/dev/null || printf '0')
	if (( now - lock_mtime >= lock_ttl )); then
		rmdir "$lock_dir" 2>/dev/null || true
	fi
fi

if (( stale )) && mkdir "$lock_dir" 2>/dev/null; then
	(
		trap 'rmdir "$lock_dir"' EXIT
		# DAGMan controllers are orchestration jobs, not fit workers, so omit them.
		states=$(timeout 10s condor_q -nobatch -af:t JobStatus Cmd 2>/dev/null) || {
			printf '%s' '#[fg=#f9e2af]󱗼 ?#[default]' >"$cache_file"
			exit 0
		}

		idle=0 running=0 held=0
		while IFS=$'\t' read -r state cmd; do
			[[ ${cmd##*/} == condor_dagman ]] && continue
			case $state in
				1) ((idle++)) ;;
				2) ((running++)) ;;
				5) ((held++)) ;;
			esac
		done <<<"$states"

		if (( held )); then
			status="#[fg=#f38ba8]󱗼 R:${running} I:${idle} H:${held}#[default]"
		else
			status="#[fg=#a6e3a1]󱗼 R:${running} I:${idle} H:0#[default]"
		fi
		tmp_file=$(mktemp "$cache_dir/status.XXXXXX") || exit 0
		printf '%s' "$status" >"$tmp_file"
		mv -f -- "$tmp_file" "$cache_file"
	) >/dev/null 2>&1 &
fi

if [[ -f $cache_file ]]; then
	cat -- "$cache_file"
else
	printf '%s' '#[fg=#cdd6f4]󱗼 …#[default]'
fi
