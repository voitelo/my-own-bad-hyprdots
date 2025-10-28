#!/usr/bin/env bash

# -----------------------------
# Paths
# -----------------------------
THEMES_DIR="$HOME/.config/hypr/themes"
UTILITY_DIR="$HOME/.config/utility"
BACKUP_DIR="$UTILITY_DIR/.config-backup"

mkdir -p "$BACKUP_DIR"

# -----------------------------
# Pick theme via rofi
# -----------------------------
THEME=$(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | rofi -dmenu -p "Select theme:")
[ -z "$THEME" ] && exit 0

THEME_PATH="$THEMES_DIR/$THEME"

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
        swaybg -i "$WALLPAPER" -m fill &
    fi
fi

# -----------------------------
# Reload apps
# -----------------------------
# Reload kitty
if pgrep -x kitty >/dev/null; then
    pkill -SIGUSR1 kitty
fi

# Reload qutebrowser
if pgrep -x qutebrowser >/dev/null; then
    qutebrowser ":config-source"
fi

echo "Theme switched to $THEME"

