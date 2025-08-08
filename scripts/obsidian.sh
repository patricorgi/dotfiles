#!/opt/homebrew/bin/bash
# to use nix-darwin #!/run/current-system/sw/bin/bash

focus_kitty_window() {
	search="$1"
	echo "[DEBUG] Searching for cwd match: $search"
	win_json=$(/opt/homebrew/bin/kitty @ --to=unix:/tmp/mykitty ls)
	echo "[DEBUG] kitty ls output: $win_json"
	win_id=$(echo "$win_json" | /usr/bin/jq -r --arg s "$search" '
		.[]
		| .tabs[]
		| .windows[]
		| select(
			.cwd | test($s)
		)
		| .id
	' | /usr/bin/head -n 1)
	echo "[DEBUG] Matched window ID: $win_id"
	if [ -n "$win_id" ]; then
		echo "$win_id"
		/opt/homebrew/bin/kitty @ --to=unix:/tmp/mykitty focus-window --match id:"$win_id"
		return 0
	else
		osascript -e 'display notification "No matching kitty window" with title "kitty"'
		return 1
	fi
}

if ! focus_kitty_window "Obsidian Vault"; then
	/opt/homebrew/bin/kitty \
		--title "obsidian" \
		--single-instance \
		-d '/Users/patricorgi/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault' \
		-- nvim
fi
