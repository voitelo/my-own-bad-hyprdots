#!/bin/bash

# Wallpaper Menu Script (Rofi, with dedicated theme)

# Wallpaper options with unique icons and real file names
wp1="🖼 lightV.png"
wp2="🎬 e.mp4"
wp3="🎥 ee.mp4"
wp4="📽 eee.mp4"

# Show menu
selected_option=$(echo -e "$wp1\n$wp2\n$wp3\n$wp4" |
  rofi -dmenu -i -p "Wallpapers" -theme ~/.config/rofi/wallpaper.rasi)

# Exit if nothing selected
[ -z "$selected_option" ] && exit

# Kill any existing wallpaper processes
pkill swaybg
pkill mpvpaper

# Apply wallpaper depending on selection
case "$selected_option" in
"$wp1")
  swaybg -i ~/lightV.png -m fill &
  ;;
"$wp2")
  mpvpaper -vs -o "no-audio loop" eDP-1 /home/leg/Animated-Wallpapers/e.mp4 &
  ;;
"$wp3")
  mpvpaper -vs -o "no-audio loop" eDP-1 /home/leg/Animated-Wallpapers/ee.mp4 &
  ;;
"$wp4")
  mpvpaper -vs -o "no-audio loop" eDP-1 /home/leg/Animated-Wallpapers/eee.mp4 &
  ;;
esac
