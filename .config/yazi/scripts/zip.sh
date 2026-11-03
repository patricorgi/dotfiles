#!/bin/bash

# Ensure at least one argument is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <folder1> [folder2] ..."
  exit 1
fi

process_folder() {
  local folderName="$1"

  if [ ! -d "$folderName" ]; then
    echo "Error: '$folderName' is not a directory"
    return
  fi

  # Convert all webp files to jpg
  shopt -s nullglob # Avoid running the loop if no .webp files exist
  for file in "$folderName"/*.webp; do
    magick convert "$file" -quality 90 "${file%.webp}.jpg" && trash "$file"
    echo "Converted: $file -> ${file%.webp}.jpg"
  done

  # Zip the folder and delete it
  zip -jr "${folderName}.zip" "$folderName" 2>/dev/null && trash "$folderName"
  echo "Zipped and removed: $folderName"
}

# Iterate over each provided folder
for folderName in "$@"; do
  process_folder "$folderName" &
done

wait
