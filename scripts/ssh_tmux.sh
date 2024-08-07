#!/bin/bash

focus_kitty_window() {
	search="$1"
	echo "[DEBUG] Searching for: $search"
	win_json=$(/opt/homebrew/bin/kitty @ --to=unix:/tmp/mykitty ls)
	echo "[DEBUG] kitty ls output: $win_json"
	win_id=$(echo "$win_json" | /usr/bin/jq -r --arg s "$search" '
		.[]
		| .tabs[]
		| .windows[]
		| select(
			.foreground_processes[]?.cmdline
			| join(" ")
			| test($s)
		)
		| .id
	' | /usr/bin/head -n 1)
	echo "[DEBUG] Matched window ID: $win_id"
	if [ -n "$win_id" ]; then
		echo "$win_id"
		/opt/homebrew/bin/kitty @ --to=unix:/tmp/mykitty focus-window --match id:"$win_id"
		return 0
	else
		osascript -e 'display notification "No existing kitty window with title '$hostname'. Launching new one..." with title "kitty"'
		return 1
	fi
}

hostname="$1"
if ! focus_kitty_window "$hostname"; then
	/opt/homebrew/bin/kitty \
		--title "$hostname" \
		--single-instance \
		-d ~ \
		-- kitty +kitten ssh "$hostname" -t 'bash -i -c tm'
fi

# aerospace legacy
# windows=$(aerospace list-windows --all)
# window_info=$(echo "$windows" | grep -v grep | grep "$hostname")
# if [[ -n "$window_info" ]]; then
# 	# osascript -e 'display notification "Kitty window with title '"${window_info}"' already exists." with title "kitty"'
# 	aerospace focus --window-id "$(echo $window_info | awk '{print $1}')"
# else
# 	# osascript -e 'display notification "No existing kitty window with title '$hostname'. Launching new one..." with title "kitty"'
# 	/opt/homebrew/bin/kitty \
# 		--title "$hostname" \
# 		--single-instance \
# 		-d ~ \
# 		-- bash -l -c "kitty +kitten ssh \"$hostname\" -t 'bash -i -c tm'"
# fi

# Ghostty
# open -na Ghostty --args --quit-after-last-window-closed=true --command="/opt/homebrew/bin/bash -c 'TERM=xterm-256color /usr/bin/ssh $1'"
# /Applications/kitty.app/Contents/MacOS/kitty +kitten ssh "$1" -t 'bash -i -c "tm"'
