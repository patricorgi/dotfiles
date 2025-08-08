#!/bin/bash

# Usage: ./trim_video.sh -f /path/to/video.mp4 -t 00:00:05

while getopts f:t: flag; do
	case "${flag}" in
	f) infile=${OPTARG} ;;
	t) time=${OPTARG} ;;
	esac
done

if [ -z "$infile" ] || [ -z "$time" ]; then
	echo "Usage: $0 -f <input_file> -t <start_time>"
	exit 1
fi

# Generate a 10-character random string (uppercase letters and digits)
rand_string=$(LC_ALL=C tr -dc 'A-Z0-9' </dev/urandom | head -c 10)

# Get directory and file extension
dir=$(dirname "$infile")
ext="${infile##*.}"

tmpfile="${dir}/${rand_string}.${ext}"

# Run ffmpeg
/opt/homebrew/bin/ffmpeg -ss "$time" -i "$infile" -c copy "$tmpfile"

# Replace original file with the trimmed one
mv "$tmpfile" "$infile"
