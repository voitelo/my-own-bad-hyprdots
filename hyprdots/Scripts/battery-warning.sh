#!/bin/bash

# Battery paths (check for BAT0 or BAT1)
if [ -d "/sys/class/power_supply/BAT0" ]; then
    BAT_PATH="/sys/class/power_supply/BAT0"
elif [ -d "/sys/class/power_supply/BAT1" ]; then
    BAT_PATH="/sys/class/power_supply/BAT1"
else
    notify-send -u low "Battery Monitor" "No battery found!"
    exit 1
fi

# Thresholds
WARN_20=20
WARN_10=10
WARN_5=5

warned_20=0
warned_10=0
warned_5=0
shutdown_scheduled=0

while true; do
    capacity=$(cat "$BAT_PATH/capacity")
    status=$(cat "$BAT_PATH/status")

    if [[ "$status" != "Charging" && "$status" != "Full" ]]; then
        if (( capacity <= WARN_20 && warned_20 == 0 && capacity > WARN_10 )); then
            notify-send -u normal -t 10000 "Battery Warning" "Battery below 20% ($capacity%). Please charge."
            warned_20=1
        elif (( capacity <= WARN_10 && warned_10 == 0 && capacity > WARN_5 )); then
            notify-send -u critical -t 10000 "Battery Warning" "Battery below 10% ($capacity%). Charge immediately!"
            warned_10=1
        elif (( capacity <= WARN_5 && warned_5 == 0 )); then
            notify-send -u critical -t 20000 "Battery Critical" "Battery below 5% ($capacity%). System will shut down in 1 minute."
            warned_5=1
            if (( shutdown_scheduled == 0 )); then
                shutdown_scheduled=1
                sudo shutdown -h +1 "Battery critically low. System shutting down."
            fi
        fi
    else
        warned_20=0
        warned_10=0
        warned_5=0
        shutdown_scheduled=0
    fi

    sleep 60
done
