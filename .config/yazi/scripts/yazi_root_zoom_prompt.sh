#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

[[ $# -eq 1 ]] || { printf 'Select one ROOT macro to zoom\n' >&2; exit 2; }

read -r -p 'xmin: ' xmin
read -r -p 'ymin: ' ymin
read -r -p 'xmax: ' xmax
read -r -p 'ymax: ' ymax

number='^-?[0-9]+([.][0-9]*)?([eE][+-]?[0-9]+)?$'
for value in "$xmin" "$ymin" "$xmax" "$ymax"; do
  [[ $value =~ $number ]] || { printf 'All zoom limits must be numeric\n' >&2; exit 2; }
done

exec "$script_dir/yazi_root_zoom.sh" "$1" "$xmin" "$ymin" "$xmax" "$ymax"
