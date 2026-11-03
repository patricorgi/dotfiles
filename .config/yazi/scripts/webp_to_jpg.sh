#!/bin/bash

if [ $# -eq 0 ]; then
  echo "No arguments provided."
  exit 1
fi

for file in *.webp; do
  convert "$file" -quality 90"${file%.webp}.jpg"
done
