#!/bin/bash

yabai_float=(
  update_freq=3 
  script="$CONFIG_DIR/plugins/yabai_float.sh" 
  click_script="$CONFIG_DIR/plugins/yabai_float_click.sh" 
)

sketchybar -m --add item yabai_float left \
              --set yabai_float "${yabai_float[@]}" \
              --add event update_float \
              --subscribe yabai_float space_change update_float
