#!/bin/bash

# Kill existing wallpaper processes
pkill swaybg
pkill swww

# Launch swww daemon if not running
swww-daemon

# Launch hyprwat to pick a wallpaper and store the path
selected_wallpaper=$(hyprwat --wallpaper ~/Wallpapers)

# Exit if nothing selected
[ -z "$selected_wallpaper" ] && exit

# Apply the wallpaper
swww img --transition-type wipe "$selected_wallpaper" &

