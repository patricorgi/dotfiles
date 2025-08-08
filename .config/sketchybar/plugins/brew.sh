#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

COUNT=$(brew outdated | wc -l | tr -d ' ')

COLOR=$RED

case "$COUNT" in
  [3-5][0-9]) COLOR=$ORANGE
  ;;
  [1-2][0-9]) COLOR=$YELLOW
  ;;
  [1-9]) COLOR=$WHITE
  ;;
  0) COLOR=$GREEN
     COUNT=􀆅
  ;;
esac
if [ "$COUNT" -gt 0 ]; then
  sketchybar --set $NAME label=$COUNT icon.color=$COLOR labal.drawing=on icon.drawing=on
else
  sketchybar --set $NAME label.drawing=off icon.drawing=off
fi
