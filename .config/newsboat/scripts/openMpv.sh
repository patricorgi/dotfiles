#!/usr/bin/env bash

# set -o errexit
# set -o pipefail
# set -o nounset

if [ $# -eq 0 ]; then
	osascript -e 'display notification "No argument provided" with title "mpv"'
	exit 1
fi

url="${1}"
# echo "url: $url"

if [[ -e "$url" ]]; then
	mpv "$url"
elif [[ "$url" =~ "bilibili" ]]; then
	socket_id=$RANDOM
	osascript -e 'display notification "Processing url..." with title "mpv"'
	mpv "$url" \
		--force-window=immediate \
		--no-fs \
		--referrer='https://www.bilibili.com' \
		--no-border \
		--input-ipc-server="/tmp/mpv-socket-$socket_id" &
	osascript -e 'display notification "Downloading danmaku..." with title "mpv"'
	xml_path=$(yt-dlp "$url" --write-subs --skip-download -P /tmp |
		grep 'Writing video subtitles' |
		sed "s|\[info\] Writing video subtitles to: ||g")
	ass_path="${xml_path/xml/ass}"
	danmaku2ass "$xml_path" \
		-s 1920x1080 \
		-o "${ass_path}" \
		-fn "Yuanti SC" \
		-fs 42 -a 0.8 -p 270 -dm 10
	echo $ass_path
	echo "{ \"command\": [\"sub-add\",\"$ass_path\"] }" |
		/opt/homebrew/bin/socat - "/tmp/mpv-socket-$socket_id"
	osascript -e 'display notification "Loaded danmaku..." with title "mpv"'
elif [[ "$url" =~ "youtube" ]]; then
	mpv "$url" \
		--force-window=immediate \
		--ytdl-format="bv+ba" \
		--no-border &
fi
