#!/bin/bash

# Directories
IMG_DIR="$HOME/other-wallpapers"

# Prepare associative array
declare -A wallpaper_map
menu_entries=""

# Images
while IFS= read -r img; do
    name="$(basename "$img")"
    display="🖼 $name"
    menu_entries+="$display\n"
    wallpaper_map["$display"]="$img"
done < <(find "$IMG_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) 2>/dev/null)

# Show menu (only filenames)
selected_display=$(echo -e "$menu_entries" | \
    fuzzel --dmenu -i -p "Wallpapers")

# Exit if nothing selected
[ -z "$selected_display" ] && exit

# Get actual path
selected_option="${wallpaper_map[$selected_display]}"

# Kill existing wallpaper processes
killall swww

# Apply wallpaper
case "$selected_option" in
    *.png)
        rm -r .cache/swww/
        swww-daemon
        swww img --transition-type random "$selected_option" &
        ;;
esac
