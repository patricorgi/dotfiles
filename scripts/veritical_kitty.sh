#!/bin/bash
osascript <<EOF
tell application "System Events"
    tell application process "kitty"
        set frontmost to true
        try
            set theWindow to window 1
            set size of theWindow to {720, 1280}
        end try
    end tell
end tell
EOF
