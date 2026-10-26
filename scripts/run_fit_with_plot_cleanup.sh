#!/usr/bin/env bash
set -u

if (( $# == 0 )); then
  printf 'Usage: %s <fit-command> [argument ...]\n' "${0##*/}" >&2
  exit 2
fi

status=0
"$@" || status=$?

# Keep generated plot macros but remove their large intermediate MC trees.
shopt -s nullglob
for root_file in plots/*/MC_TotalFit.root; do
  plot_dir=${root_file%/*}
  macros=("$plot_dir"/*.C)
  (( ${#macros[@]} > 0 )) && rm -f -- "$root_file"
done

exit "$status"
