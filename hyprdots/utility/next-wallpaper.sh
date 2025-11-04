#!/usr/bin/env bash

# -----------------------------
# Paths
# -----------------------------
UTILITY_DIR="$HOME/.config/utility"
THEMES_DIR="$HOME/.config/hypr/themes"

# -----------------------------
# Get current theme
# -----------------------------
if [ ! -f "$UTILITY_DIR/current_theme" ]; then
    echo "No current theme found!"
    exit 1
fi

THEME=$(cat "$UTILITY_DIR/current_theme")
THEME_PATH="$THEMES_DIR/$THEME"
WALLPAPER_DIR="$THEME_PATH/wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "No wallpapers folder for $THEME"
    exit 1
fi

# -----------------------------
# Track wallpaper index per theme
# -----------------------------
INDEX_FILE="$UTILITY_DIR/.last_wallpaper_index_$THEME"
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) | sort)
TOTAL=${#WALLPAPERS[@]}

if [ "$TOTAL" -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get previous index
if [ -f "$INDEX_FILE" ]; then
    INDEX=$(<"$INDEX_FILE")
else
    INDEX=0
fi

# Increment and wrap around
INDEX=$(( (INDEX + 1) % TOTAL ))
echo "$INDEX" > "$INDEX_FILE"

# -----------------------------
# Apply wallpaper
# -----------------------------
WALLPAPER="${WALLPAPERS[$INDEX]}"

# Set wallpaper (background fill)
swww_handler="swww-daemon"
if ! pgrep -x "$swww_handler" > /dev/null; then
    swww-daemon
fi

swww img --transition-type wipe "$WALLPAPER"

notify-send "🐾 Wallpaper changed" "$(basename "$WALLPAPER")" -t 2000

echo "Wallpaper switched to: $(basename "$WALLPAPER")"

