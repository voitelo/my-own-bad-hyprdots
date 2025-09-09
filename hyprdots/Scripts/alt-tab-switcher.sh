#!/bin/bash

# Get list of open windows (address and class only)
selected=$(hyprctl clients -j | jq -r '.[] | "\(.address): \(.class)"' | wofi --dmenu -i -p "Window Switcher")

# If user canceled or nothing selected, exit
[ -z "$selected" ] && exit

# Extract address (everything before the first ':')
address="${selected%%:*}"

# Focus the selected window using its address
hyprctl dispatch focuswindow address:$address
