#!/bin/bash

# Directories
IMG_DIR="$HOME/wallpapers"
IMG_DIRR="$HOME/Wallpapers"
VID_DIR="$HOME/Animated-Wallpapers"

# Prepare associative array
declare -A wallpaper_map
menu_entries=""

# Images
while IFS= read -r img; do
    name="$(basename "$img")"
    display="🖼 $name"
    menu_entries+="$display\n"
    wallpaper_map["$display"]="$img"
done < <(find "$IMG_DIR" "$IMG_DIRR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) 2>/dev/null)

# Videos
while IFS= read -r vid; do
    name="$(basename "$vid")"
    display="🎥 $name"
    menu_entries+="$display\n"
    wallpaper_map["$display"]="$vid"
done < <(find "$VID_DIR" -type f -iname "*.mp4" 2>/dev/null)

# Show menu (only filenames)
selected_display=$(echo -e "$menu_entries" | \
    rofi -dmenu -i -p "Wallpapers")

# Exit if nothing selected
[ -z "$selected_display" ] && exit

# Get actual path
selected_option="${wallpaper_map[$selected_display]}"

# Kill existing wallpaper processes
pkill swaybg
pkill mpvpaper

# Apply wallpaper
case "$selected_option" in
    *.png|*.jpg|*.jpeg)
        swaybg -i "$selected_option" &
        ;;
    *.mp4)
        mpvpaper -vs -o "no-audio loop" eDP-1 "$selected_option" &
        ;;
esac

