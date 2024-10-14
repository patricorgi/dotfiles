#!/run/current-system/sw/bin/bash

hostname="$1"
if [ -x "$(command -v aerospace)" ]; then
	windows=$(aerospace list-windows --all)
	window_info=$(echo "$windows" | grep -v grep | grep "$hostname")
	if [[ -n "$window_info" ]]; then
		# osascript -e 'display notification "Kitty window with title '"${window_info}"' already exists." with title "kitty"'
		aerospace focus --window-id "$(echo $window_info | awk '{print $1}')"
	else
		# osascript -e 'display notification "No existing kitty window with title '$hostname'. Launching new one..." with title "kitty"'
		/opt/homebrew/bin/kitty \
			--title "$hostname" \
			--single-instance \
			-d ~ \
			-- bash -l -c "kitty +kitten ssh \"$hostname\" -t 'bash -i -c tm'"
	fi
else
	# TODO: find a non-aerospace way to check if the ssh window exists
	/opt/homebrew/bin/kitty \
		--title "$hostname" \
		--single-instance \
		-d ~ \
		-- bash -l -c "kitty +kitten ssh \"$hostname\" -t 'bash -i -c tm'"
fi

# Ghostty
# open -na Ghostty --args --quit-after-last-window-closed=true --command="/opt/homebrew/bin/bash -c 'TERM=xterm-256color /usr/bin/ssh $1'"
# /Applications/kitty.app/Contents/MacOS/kitty +kitten ssh "$1" -t 'bash -i -c "tm"'
