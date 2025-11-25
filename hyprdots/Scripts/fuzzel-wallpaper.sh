#!/bin/bash

# Directories
IMG_DIR="$HOME/wallpapers"
IMG_DIRR="$HOME/Wallpapers"

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

# Show menu (only filenames)
selected_display=$(echo -e "$menu_entries" | \
    fuzzel --dmenu -i -p "Wallpapers")

# Exit if nothing selected
[ -z "$selected_display" ] && exit

# Get actual path
selected_option="${wallpaper_map[$selected_display]}"

# Kill existing wallpaper processes
pkill swaybg
pkill swww

# Apply wallpaper
case "$selected_option" in
    *.png|*.jpg|*.jpeg)
        swww-daemon
        swww img --transition-type wipe "$selected_option" &
        ;;
esac

