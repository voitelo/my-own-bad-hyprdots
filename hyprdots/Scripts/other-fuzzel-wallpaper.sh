#!/bin/bash

# Kill existing wallpaper processes
killall swww
killall swww-daemon

# Clear swww cache like your original script
rm -r ~/.cache/swww/ 2>/dev/null

# Launch swww daemon
swww-daemon

# Pick a wallpaper with hyprwat
selected_wallpaper=$(hyprwat --wallpaper ~/other-wallpapers)

# Exit if nothing selected
[ -z "$selected_wallpaper" ] && exit

# Apply the wallpaper
swww img --transition-type random "$selected_wallpaper" &

