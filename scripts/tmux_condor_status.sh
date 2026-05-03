#!/usr/bin/env bash

# Cache condor_q output so tmux status redraws stay cheap.
cache_root=${TMPDIR:-/tmp}
cache_dir="${cache_root%/}/tmux-condor-status-$UID"
cache_file="$cache_dir/status"
lock_dir="$cache_dir/lock"
cache_ttl=20
lock_ttl=120

command -v condor_q >/dev/null 2>&1 || exit 0

mkdir -p "$cache_dir"

now=$(date +%s)
stale=1

if [ -f "$cache_file" ]; then
	cache_mtime=$(stat -f %m "$cache_file" 2>/dev/null || printf '0')
	if [ $((now - cache_mtime)) -lt "$cache_ttl" ]; then
		stale=0
	fi
fi

if [ -d "$lock_dir" ]; then
	lock_mtime=$(stat -f %m "$lock_dir" 2>/dev/null || printf '0')
	if [ $((now - lock_mtime)) -ge "$lock_ttl" ]; then
		rmdir "$lock_dir" 2>/dev/null || true
	fi
fi

if [ "$stale" -eq 1 ] && mkdir "$lock_dir" 2>/dev/null; then
	(
		trap 'rmdir "$lock_dir"' EXIT
		output=$(condor_q -totals 2>/dev/null | grep query | awk '/jobs;/ && $4 > 0 {print "󱗼 " $14 "/" $10 "/" $12}')
		tmp_file=$(mktemp "$cache_dir/status.XXXXXX") || exit 0
		printf '%s' "$output" >"$tmp_file"
		mv "$tmp_file" "$cache_file"
	) >/dev/null 2>&1 &
fi

if [ -f "$cache_file" ]; then
	cat "$cache_file"
fi
