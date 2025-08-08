#!/bin/bash
yabai -m window --toggle float

yabai_float=$(yabai -m query --windows --window | jq .floating)

case "$yabai_float" in
    0)
    sketchybar -m --set yabai_float label=""
    ;;
    1)
    sketchybar -m --set yabai_float label=""
    ;;
esac
