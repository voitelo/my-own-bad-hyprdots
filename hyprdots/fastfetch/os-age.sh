#!/bin/bash

# Try method 1: Use filesystem creation time from tune2fs
device=$(df / | tail -1 | awk '{print $1}')

creation_time=$(tune2fs -l "$device" 2>/dev/null | grep "Filesystem created:" | cut -d":" -f2- | xargs)

if [ -n "$creation_time" ]; then
    install_timestamp=$(date -d "$creation_time" +%s)
    current_timestamp=$(date +%s)
    age_days=$(( (current_timestamp - install_timestamp) / 86400 ))
    echo "$age_days days ago"
else
    echo "Unknown"
fi
