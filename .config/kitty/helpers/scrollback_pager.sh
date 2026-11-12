#!/usr/bin/env bash
set -o pipefail

# Unwrap Kitty's OSC 66 text sizing codes, preserving their text and ANSI colours.
perl -pe 's/\e\]66;[^;\e\a]*;([^\e\a]*)(?:\a|\e\\)/$1/g' |
	less --chop-long-lines --RAW-CONTROL-CHARS -+F "$@"
