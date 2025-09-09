#!/bin/bash

# Get current sensitivity
current=$(hyprctl getoption input:sensitivity | grep 'float' | awk '{print $2}')

# Format current to match decimal precision
current=$(printf "%.3f" "$current")

if [[ "$current" == "-0.950" ]]; then
    hyprctl keyword input:sensitivity 0.0
    notify-send "Pointer sensitivity set to 0.0"
else
    hyprctl keyword input:sensitivity -0.950
    notify-send "Pointer sensitivity set to -0.950"
fi
