#!/bin/bash

front_app=(
  icon.color=$WHITE
  icon.font="sketchybar-app-font:Regular:16.0" 
  label.color=$WHITE
  label.font="SF Pro:Bold:16"
  padding_left=0
  padding_right=10
  script="$PLUGIN_DIR/front_app.sh"            
)

sketchybar --add item front_app left \
           --set front_app "${front_app[@]}" \
           --subscribe front_app front_app_switched

# status_bracket=(
  # background.color=$WHITE
  # background.color=$BACKGROUND_1
  # background.border_color=$BACKGROUND_2
  # background.border_width=2
  # background.padding_left=5
# )

# sketchybar --add bracket bracket_front_app front_app \
#            --set bracket_front_app "${status_bracket[@]}"
