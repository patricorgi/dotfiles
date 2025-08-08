#!/bin/bash

[[ -f "utils/config.json" ]] || exit 1
for d in */; do
	if [ -d "$d.git" ] || [ -f "$d.git" ]; then
    submodule_path="$d"
    remote_url=$(git -C "$d" remote -v | grep "origin" | head -n 1 | cut -f2 | cut -d" " -f1)
    if [ -n "$remote_url" ]; then
      echo "[submodule \"${submodule_path/\//}\"]" >> .gitmodules
      echo "    path = ${submodule_path/\//}" >> .gitmodules
      echo "    url = $remote_url" >> .gitmodules
    fi
	fi
done

for d in DBASE/* PARAM/ParamFiles; do
	if [ -d "$d/.git" ] || [ -f "$d/.git" ]; then
    submodule_path="$d"
    remote_url=$(git -C "$d" remote -v | grep "origin" | head -n 1 | cut -f2 | cut -d" " -f1)
    if [ -n "$remote_url" ]; then
      echo "[submodule \"${submodule_path}\"]" >> .gitmodules
      echo "    path = ${submodule_path}" >> .gitmodules
      echo "    url = $remote_url" >> .gitmodules
    fi
	fi
done
