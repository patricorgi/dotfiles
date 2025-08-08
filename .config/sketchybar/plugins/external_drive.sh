#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

if diskutil info WD | grep "Mounted:\ *Yes"; then
  sketchybar -m --set external_drive icon="􀤃" \
                --set external_drive icon.color=$YELLOW \
                --set external_drive \
                --set external_drive icon.drawing=on label.drawing=off
else
  sketchybar -m --set external_drive icon.drawing=off \
                --set external_drive label.drawing=off
fi

