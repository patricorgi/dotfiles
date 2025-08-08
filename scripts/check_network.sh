#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Error: No argument provided."
    exit 1
fi

if /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep SSID | grep -v BSSID | grep $1; then
    exit 1
else
    exit 0
fi
