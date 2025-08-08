#!/bin/bash

source "$CONFIG_DIR/colors.sh"

COUNT=$(osascript -e 'tell application "Mail" to return the unread count of inbox')

COLOR=$BLUE

if [ "$COUNT" -gt 0 ]; then
  COLOR=$BLUE
  sketchybar --set $NAME label=$COUNT icon.color=$COLOR label.drawing=on icon.drawing=on
else
  sketchybar --set $NAME icon.drawing=off label.drawing=off
fi

