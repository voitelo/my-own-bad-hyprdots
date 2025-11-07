#!/usr/bin/env bash

# -----------------------------
# Paths
# -----------------------------
THEMES_DIR="$HOME/.config/hypr/themes"
UTILITY_DIR="$HOME/.config/utility"
BACKUP_DIR="$UTILITY_DIR/.config-backup"
ROFI_THEME="$HOME/.config/rofi/theme.rasi"

mkdir -p "$BACKUP_DIR"

# -----------------------------
# Pick theme via rofi
# -----------------------------
THEME=$(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | rofi -config "$ROFI_THEME" -dmenu -p "Select theme:")
[ -z "$THEME" ] && exit 0

THEME_PATH="$THEMES_DIR/$THEME"

# Save current theme for wallpaper cycling
echo "$THEME" > "$UTILITY_DIR/current_theme"

# -----------------------------
# Detect configs in theme
# -----------------------------
CONFIGS=($(find "$THEME_PATH" -maxdepth 1 -mindepth 1 -type d -printf "%f\n"))

# -----------------------------
# Backup old configs & copy new
# -----------------------------
for config in "${CONFIGS[@]}"; do
    SRC="$THEME_PATH/$config"
    DEST="$HOME/.config/$config"

    # Backup old config if it exists
    if [ -d "$DEST" ]; then
        mv "$DEST" "$BACKUP_DIR/${config}-$(date +%s)"
    fi

    # Copy new theme config
    cp -r "$SRC" "$DEST"
done

# -----------------------------
# Set wallpaper (first image)
# -----------------------------
if [ -d "$THEME_PATH/wallpapers" ]; then
    WALLPAPER=$(find "$THEME_PATH/wallpapers" -type f \( -iname "*.png" -o -iname "*.jpg" \) | head -n 1)
    if [ -n "$WALLPAPER" ]; then
        swww img --transition-type grow "$WALLPAPER"
    fi
fi

# -----------------------------
# Reload apps
# -----------------------------
pgrep -x kitty >/dev/null && pkill -SIGUSR1 kitty
pgrep -x qutebrowser >/dev/null && qutebrowser ":config-source"

notify-send -t 5000 "Theme switched to $THEME"
echo "Theme switched to $THEME"

