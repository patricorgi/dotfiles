#!/bin/bash

filename="$1"
osascript -e 'tell application id "com.runningwithcrayons.Alfred" to run trigger "yazi_to_alfred_actions" in workflow "com.terminal.utilities" with argument "'${filename}'"'
