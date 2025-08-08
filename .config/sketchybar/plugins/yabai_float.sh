#!/bin/bash

yabai_float=$(yabai -m query --windows --window | jq '."is-floating"')

case "$yabai_float" in
    false)
    sketchybar -m --set yabai_float label="􀏠" label.font="SF Pro:SemiBold:16.0"
    ;;
    true)
    sketchybar -m --set yabai_float label="􀫝" label.font="SF Pro:SemiBold:16.0"
    ;;
esac
