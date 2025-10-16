#!/bin/bash

CURSOR_CONF="$HOME/.config/hypr/cursor.conf"

# Get current cursor theme from cursor.conf, fallback to empty if not found
CURRENT_CURSOR=$(grep "^env = XCURSOR_THEME" "$CURSOR_CONF" 2>/dev/null | cut -d',' -f2 | tr -d ' ' || echo "")

# Decide next cursor theme
if [[ "$CURRENT_CURSOR" == "ArcAurora-cursors" ]]; then
    NEXT_CURSOR="Future-cursors"
else
    NEXT_CURSOR="ArcAurora-cursors"
fi

{
  echo "env = XCURSOR_THEME, $NEXT_CURSOR"
  echo "env = XCURSOR_SIZE, 24"
  echo "env = XCURSOR_PATH, ~/.icons:/usr/share/icons"
} > "$CURSOR_CONF"

# Reload Hyprland config and set cursor immediately
if hyprctl reload && hyprctl setcursor "$NEXT_CURSOR" 24; then
    notify-send "Cursor changed" "Cursor theme switched to $NEXT_CURSOR" -i cursor
else
    notify-send "Cursor change failed" "Failed to change cursor theme" -i error
fi
