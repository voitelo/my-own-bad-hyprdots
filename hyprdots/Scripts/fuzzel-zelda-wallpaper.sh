#!/bin/bash

# Kill existing wallpaper processes
killall swww
killall swww-daemon

# Launch swww daemon
swww-daemon

# Pick a Zelda wallpaper with hyprwat
selected_wallpaper=$(hyprwat --wallpaper ~/wallpaper-zelda)

# Exit if nothing selected
[ -z "$selected_wallpaper" ] && exit

# Apply the wallpaper
swww img --transition-type random "$selected_wallpaper" &

