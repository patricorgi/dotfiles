sketchybar --add item Messenger right                                               \
               --set Messenger update_freq=10                                       \
                          icon=󰈎\
                          icon.font="$FONT:GREEN:16.0"                         \
                          icon.color=$BLUE                                \
                          script="$PLUGIN_DIR/app_status_label.sh"             \
                          click_script="open -a Messenger"
