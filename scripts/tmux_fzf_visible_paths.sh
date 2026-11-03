#!/usr/bin/env bash
set -euo pipefail

command -v tmux >/dev/null 2>&1 || exit 1
command -v fzf >/dev/null 2>&1 || {
	tmux display-message "fzf not found"
	exit 1
}
command -v rg >/dev/null 2>&1 || {
	tmux display-message "rg not found"
	exit 1
}

selection=$(
	tmux list-panes -F '#{pane_id}' |
		while IFS= read -r pane; do
			tmux capture-pane -pJ -t "$pane"
		done |
		tr '[:space:]' '\n' |
		rg -o '((~|\.)?/?[A-Za-z0-9._@%+=,~-]+(/[A-Za-z0-9._@%+=,~-]+)+)' |
		sed 's/[][(){}"'"'"',.;:]*$//' |
		sort -u |
		fzf --prompt='path> ' --height=100% --layout=reverse
) || exit 0

[ -n "$selection" ] || exit 0

printf '%s' "$selection" | tmux load-buffer -w -
tmux display-message "copied: $selection"
