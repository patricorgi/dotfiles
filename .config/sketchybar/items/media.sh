#!/bin/bash
PLUGIN_DIR="$HOME/.config/sketchybar/plugins" # Directory where all the plugin scripts are stored

sketchybar --add item media e                        \
           --set media label.color=$RED              \
                       label.max_chars=20            \
                       icon.padding_left=0           \
                       scroll_texts=on               \
                       icon=􀑪                        \
                       icon.color=$RED               \
                       background.drawing=off        \
                       script="$PLUGIN_DIR/media.sh" \
           --subscribe media media_change
