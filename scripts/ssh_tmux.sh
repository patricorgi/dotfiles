#!/opt/homebrew/bin/bash
# to use nix-darwin #!/run/current-system/sw/bin/bash

focus_kitty_window() {
	search="$1"
	echo "[DEBUG] Searching for: $search"
	win_json=$(/opt/homebrew/bin/kitty @ --to=unix:/tmp/mykitty ls)
	echo "[DEBUG] kitty ls output: $win_json"
	# match by cmdline
	# win_id=$(echo "$win_json" | /usr/bin/jq -r --arg s "$search" '
	# 	.[]
	# 	| .tabs[]
	# 	| .windows[]
	# 	| select(
	# 		.foreground_processes[]?.cmdline
	# 		| join(" ")
	# 		| test($s)
	# 	)
	# 	| .id
	# ' | /usr/bin/head -n 1)
	# match by os-window title
	win_id=$(echo "$win_json" | /usr/bin/jq -r --arg s "$search" '
		.[]
		| .tabs[]
		| .windows[]
		| select(.title == $s)
		| .id
	' | /usr/bin/head -n 1)
	echo "[DEBUG] Matched window ID: $win_id"
	if [ -n "$win_id" ]; then
		echo "$win_id"
		/opt/homebrew/bin/kitty @ --to=unix:/tmp/mykitty focus-window --match id:"$win_id"
		return 0
	else
		osascript -e 'display notification "Connecting to '$hostname'" with title "kitty"'
		return 1
	fi
}

mount_this() {
	hostname="$1"
	if [ -n "$2" ]; then
		remotepath="$2"
		mountpoint=~/SSHFS/"$hostname"@$(basename $remotepath)
		echo diskutil unmount force '$mountpoint'
		diskutil unmount force '$mountpoint'
		echo mkdir -p "$mountpoint"
		mkdir -p "$mountpoint"
		echo sshfs "$hostname:$remotepath" "$mountpoint" \
			-o defer_permissions,noappledouble,nolocalcaches,no_readahead,ServerAliveInterval=5,ServerAliveCountMax=2,volname=$(basename $mountpoint)
		sshfs "$hostname:$remotepath" "$mountpoint" \
			-o defer_permissions,noappledouble,nolocalcaches,no_readahead,ServerAliveInterval=5,ServerAliveCountMax=2,volname=$(basename $mountpoint)
	else
		remotepath="$2"
		mountpoint=~/SSHFS/"$hostname"
		echo diskutil unmount force '$mountpoint'
		diskutil unmount force '$mountpoint'
		echo mkdir -p "$mountpoint"
		mkdir -p "$mountpoint"
		echo sshfs "$hostname:" "$mountpoint" \
			-o defer_permissions,noappledouble,nolocalcaches,no_readahead,ServerAliveInterval=5,ServerAliveCountMax=2,volname=$(basename $mountpoint)
		sshfs "$hostname:" "$mountpoint" \
			-o defer_permissions,noappledouble,nolocalcaches,no_readahead,ServerAliveInterval=5,ServerAliveCountMax=2,volname=$(basename $mountpoint)
	fi
}

hostname="$1"
remotepath="$2"
if ! focus_kitty_window "$hostname"; then
	pkill -f "$hostname"
	mount_this "$hostname" "$remotepath" &
	if tty -s; then
		/opt/homebrew/bin/kitty @ launch \
			--single-instance \
			--type=os-window \
			--title="${hostname}" \
			bash -c "~/dotfiles/scripts/ssh.sh \"$hostname\" \"$mountpoint\""
	else
		/opt/homebrew/bin/kitty \
			--title "$hostname" \
			--single-instance \
			--override window_logo_path=/Users/patricorgi/dotfiles/assets/nvidia.png \
			-d ~ \
			-- \
			bash -c "~/dotfiles/scripts/ssh.sh \"$hostname\" \"$mountpoint\""
	fi
fi

# ghostty
# open -na Ghostty --args --gtk-single-instance=true --quit-after-last-window-closed=true --command="bash -i -c \"TERM=xterm-256color /usr/bin/ssh $hostname -t 'bash -i -c tm'\""

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
