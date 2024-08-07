#!/bin/bash

sketchybar -m --add event external_drive_update \
              --add item external_drive right \
              --set external_drive update_freq=300 \
              --set external_drive script="~/.config/sketchybar/plugins/external_drive.sh" \
              --subscribe external_drive external_drive_update
