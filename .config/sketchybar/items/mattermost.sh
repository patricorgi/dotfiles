sketchybar --add item Mattermost right                                           \
               --set Mattermost update_freq=10                                   \
                          icon=\
                          icon.font="JetBrainsMono Nerd Font:WHITE:16.0"         \
                          icon.color=$BLUE                                       \
                          script="$PLUGIN_DIR/app_status_label.sh"               \
                          click_script="open -a Mattermost"                      

