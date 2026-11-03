#!/usr/bin/env bash
# Open lhcb-proxy-init in a tmux popup. The popup closes on success.
set -euo pipefail

if ! command -v tmux >/dev/null 2>&1; then
  printf 'tmux is not installed.\n' >&2
  exit 1
fi

if [[ -n ${TMUX:-} ]]; then
	target=$(tmux display-message -p '#{client_name}')
else
	# OpenCode tool shells belong to the server rather than the attached client,
	# so they generally do not inherit TMUX. Target the sole attached client.
	mapfile -t clients < <(tmux list-clients -F '#{client_name}' 2>/dev/null || true)
	if (( ${#clients[@]} == 0 )); then
		printf 'No attached tmux client was found. Attach tmux and try again.\n' >&2
		exit 1
	fi
	if (( ${#clients[@]} > 1 )); then
		printf 'More than one tmux client is attached; run this from the intended tmux pane.\n' >&2
		exit 1
	fi
	target=${clients[0]}
fi

tmux display-popup -t "${target}" -E -w 80% -h 40% \
  "bash -lc 'source /cvmfs/lhcb.cern.ch/lib/LbEnv && exec lhcb-proxy-init'"
