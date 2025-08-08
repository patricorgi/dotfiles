#!/bin/bash

[[ -f "utils/config.json" ]] || exit 1
for d in */; do
	if [ -d "$d.git" ] || [ -f "$d.git" ]; then
		printf "%-15s\t%-20s\n" "${d/\//}" $(git -C "$d" branch --show-current)
	fi
done
