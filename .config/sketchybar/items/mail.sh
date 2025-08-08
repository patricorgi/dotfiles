#!/bin/bash

# Trigger the brew_udpate event when brew update or upgrade is run from cmdline
# e.g. via function in .zshrc

mail=(
  icon=􀍖
  label=?
  script="$PLUGIN_DIR/mail.sh"
  update_freq=600
)

sketchybar --add event mail_update \
           --add item mail right   \
           --set mail "${mail[@]}" \
           --set mail click_script="~/.config/sketchybar/plugins/mail_click.sh" \
           --subscribe mail mail_update

