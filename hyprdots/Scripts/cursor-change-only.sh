#!/bin/bash

CURSOR_CONF="$HOME/.config/hypr/sources/cursor.conf"

# Gather available cursor themes
mapfile -t CURSORS < <(
    # List top-level dirs in /usr/share/icons and ~/.icons
    for dir in /usr/share/icons ~/.icons; do
        [ -d "$dir" ] || continue
        for d in "$dir"/*; do
            [ -d "$d" ] || continue
            name=$(basename "$d")
            # Exclude hicolor and AdwaitaLegacy (common non-cursor dirs)
            if [[ "$name" != "hicolor" && "$name" != "AdwaitaLegacy" ]]; then
                echo "$name"
            fi
        done
    done | sort -u
)

# Fallback if no cursors found
if [ "${#CURSORS[@]}" -eq 0 ]; then
    notify-send "Cursor change failed" "No cursor themes found" -i error
    exit 1
fi

# Show dmenu-compatible fuzzel menu and get user selection
NEXT_CURSOR=$(printf '%s\n' "${CURSORS[@]}" | fuzzel --dmenu --prompt "Select cursor theme:")

# Exit if no selection made
if [ -z "$NEXT_CURSOR" ]; then
    exit 0
fi

# Write new cursor settings to cursor.conf
{
  echo "env = XCURSOR_THEME, $NEXT_CURSOR"
  echo "env = XCURSOR_SIZE, 24"
  echo "env = XCURSOR_PATH, ~/.icons:/usr/share/icons"
} > "$CURSOR_CONF"

# Reload Hyprland config and apply cursor immediately
if hyprctl reload && hyprctl setcursor "$NEXT_CURSOR" 24; then
    notify-send "Cursor changed" "Cursor theme switched to $NEXT_CURSOR" -i cursor
else
    notify-send "Cursor change failed" "Failed to change cursor theme" -i error
fi

