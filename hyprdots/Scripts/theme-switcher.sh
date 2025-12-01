#!/usr/bin/env bash

# -----------------------------
# Paths
# -----------------------------
THEMES_DIR="$HOME/.config/hypr/themes"
UTILITY_DIR="$HOME/.config/utility"
BACKUP_DIR="$UTILITY_DIR/.config-backup"

mkdir -p "$BACKUP_DIR"

# -----------------------------
# Pick theme via fuzzel
# -----------------------------
THEME=$(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" \
    | fuzzel --dmenu -p "Select theme:")
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

    [ -d "$DEST" ] && mv "$DEST" "$BACKUP_DIR/${config}-$(date +%s)"
    cp -r "$SRC" "$DEST"
done

# -----------------------------
# Set wallpaper (first image)
# -----------------------------
if [ -d "$THEME_PATH/wallpapers" ]; then
    WALLPAPER=$(find "$THEME_PATH/wallpapers" -type f \( -iname "*.png" -o -iname "*.jpg" \) | head -n 1)
    [ -n "$WALLPAPER" ] && swww img --transition-type grow "$WALLPAPER"
fi

# -----------------------------
# Reload apps via hooks
# -----------------------------
for hook in "$UTILITY_DIR"/reload-hooks.d/*.sh; do
    [ -x "$hook" ] && "$hook"
done

# -----------------------------
# Apply Caelestia theme
# -----------------------------
apply_caelestia_theme() {
    local name="$1"
    local flavor="$2"
    local mode="$3"

    # Ensure Caelestia is running
    if pgrep -f "caelestia" >/dev/null 2>&1; then
        caelestia scheme set -n "$name" -f "$flavor" -m "$mode"
        notify-send "Caelestia theme applied: $name"
    fi
}

# Map theme names exactly as they appear in THEME
case "$THEME" in
    "Rosepine")
        apply_caelestia_theme "rosepine" "moon" "dark"
        ;;
    "Gruvbox")
        apply_caelestia_theme "gruvbox" "soft" "dark"
        ;;
    "Catpuccin-Mocha (default)")
        apply_caelestia_theme "catppuccin" "frappe" "dark"
        ;;
    "Everforest")
        apply_caelestia_theme "darkgreen" "medium" "dark"
        ;;
esac

# -----------------------------
# Notify theme switch
# -----------------------------
notify-send -t 5000 "Theme switched to $THEME"
echo "Theme switched to $THEME"

