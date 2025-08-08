#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"
TODAY_ITEMS_COUNT=$(osascript -e 'tell application "Things3" to return count of (to dos of list "Today" where its status is not completed)')

if [ "$TODAY_ITEMS_COUNT" -gt 0 ]; then
  COLOR=$RED
else
  COLOR=$GREEN
  COUNT=􀆅
fi
if [[ $TODAY_ITEMS_COUNT -gt 0 ]]; then
  sketchybar -m --set things icon="􀃳" \
                --set things label="$TODAY_ITEMS_COUNT" \
                --set things icon.color=$COLOR \
                --set things label.drawing=on \
                --set things icon.drawing=on
else
  # sketchybar -m --set things icon="" \
  #               --set things label=""
  sketchybar -m --set things icon.drawing=off \
                --set things label.drawing=off
fi
