#!/bin/bash

# Check if a folder is provided
if [ $# -ne 1 ]; then
	echo "Usage: $0 <image-folder>"
	exit 1
fi

folder="$1"

# Check if ImageMagick is installed
if ! command -v /opt/homebrew/bin/identify &>/dev/null; then
	osascript -e 'display notification "Error: ImageMagick is not installed (Linux)." with title "'"$0"'"'
	exit 1
fi

# Define aspect ratio threshold for landscape wallpapers
min_aspect_ratio=1.45 # Example: 16:11 (1.45) 16:10 (1.6), 16:9 (1.78), etc.

# Find all image files in the folder
shopt -s nullglob # Prevents errors if no images are found
images=("$folder"/*.{jpg,jpeg,png,gif})

# Check if there are images in the folder
if [ ${#images[@]} -eq 0 ]; then
	osascript -e 'display notification "No images found in the folder" with title "'"$0"'"'
	exit 1
fi

# Loop until a suitable image is found
while true; do
	# Pick a random image
	image="${images[RANDOM % ${#images[@]}]}"

	# Get image dimensions
	read -r width height < <(identify -format "%w %h" "$image" 2>/dev/null)

	# Check if identify succeeded
	if [ -z "$width" ] || [ -z "$height" ]; then
		echo "Error: Unable to determine image dimensions for $image."
		continue
	fi

	# Calculate aspect ratio
	aspect_ratio=$(echo "scale=4; $width / $height" | bc)

	# Check if it's a landscape wallpaper
	if (($(echo "$aspect_ratio >= $min_aspect_ratio" | bc -l))); then
		echo "$image"
		exit 0
	fi
done
