#!/bin/env bash

WALLPAPER1="/home/leg/Animated-Wallpapers/eee.mp4"
WALLPAPER2="/home/leg/Animated-Wallpapers/e.mp4"
WALLPAPER3="/home/leg/Animated-Wallpapers/ee.mp4"

# Kill existing swaybg only once
pkill mpv 2>/dev/null

if [[ -f "$CURRENT_WALLPAPER_FILE" ]]; then
    CURRENT_WALLPAPER=$(<"$CURRENT_WALLPAPER_FILE")
else
    CURRENT_WALLPAPER="$WALLPAPER1"
fi

case "$CURRENT_WALLPAPER" in
    "$WALLPAPER1") NEW_WALLPAPER="$WALLPAPER2" ;;
    "$WALLPAPER2") NEW_WALLPAPER="$WALLPAPER3" ;;
    *) NEW_WALLPAPER="$WALLPAPER1" ;;
esac

# Always use mpvpaper
mpvpaper -vs -o "no-audio loop" eDP-1 "$NEW_WALLPAPER" &

echo "$NEW_WALLPAPER" > "$CURRENT_WALLPAPER_FILE"
# notify-send "Wallpaper toggled" "Now showing: $(basename "$NEW_WALLPAPER")"
