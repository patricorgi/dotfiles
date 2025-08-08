#!/bin/bash

sketchybar -m --add event things_update \
              --add item things right \
              --set things update_freq=300 \
              --set things script="~/.config/sketchybar/plugins/things.sh" \
              --set things click_script="~/.config/sketchybar/plugins/things_click.sh" \
              --subscribe things things_update
