sketchybar --add item 微信 right                                               \
               --set 微信 update_freq=10                                       \
                          icon=󰘑\
                          icon.font="$FONT:GREEN:20.0"                         \
                          icon.padding_left=0\
                          icon.color=0xff2fb608                                \
                          script="$PLUGIN_DIR/app_status_label.sh"             \
                          click_script="open -a Wechat"
