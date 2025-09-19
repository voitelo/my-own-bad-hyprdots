#!/bin/bash

CONFIG="$HOME/.config/hypr/hyprland.conf"
BACKUP="$HOME/Downloads/hyprland.conf.bak"

# --- Backup ---
if [ -f "$CONFIG" ]; then
  [ -f "$BACKUP" ] && rm "$BACKUP"
  cp "$CONFIG" "$BACKUP"
else
  zenity --error --text="Hyprland config not found!"
  exit 1
fi

# --- Helper: Convert #RRGGBB to rgba(RRGGBBAA) ---
hex_to_rgba() {
  local hex="${1#\#}"   # Remove #
  echo "rgba(${hex}ee)" # 'ee' alpha ~0.93
}

# --- Block-aware replacement ---
replace_in_block() {
  local block="$1"
  local key="$2"
  local value="$3"

  awk -v block="$block" -v key="$key" -v value="$value" '
    BEGIN { in_block=0; brace_count=0 }
    {
        if ($0 ~ "^[[:space:]]*"block"[[:space:]]*{") {
            in_block=1; brace_count=1
        } else if (in_block) {
            n_open=gsub(/\{/, "{")
            n_close=gsub(/\}/, "}")
            brace_count += n_open - n_close
            if ($0 ~ "^[[:space:]]*"key"[[:space:]]*=" && brace_count>0) sub("=.*", "= "value)
            if (brace_count==0) in_block=0
        }
        print
    }' "$CONFIG" >"$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
}

# --- Change Border Gradient ---
change_border_gradient() {
  local start end angle gradient

  # Active border
  start=$(zenity --color-selection --title="Active Border Start") || return
  end=$(zenity --color-selection --title="Active Border End") || return
  angle=$(zenity --entry --title="Active Border Angle" --text="Enter angle (deg)" --entry-text="45") || return
  gradient="$(hex_to_rgba "$start") $(hex_to_rgba "$end") ${angle}deg"
  replace_in_block "general" "col.active_border" "$gradient"

  # Inactive border
  start=$(zenity --color-selection --title="Inactive Border Start") || return
  end=$(zenity --color-selection --title="Inactive Border End") || return
  angle=$(zenity --entry --title="Inactive Border Angle" --text="Enter angle (deg)" --entry-text="45") || return
  gradient="$(hex_to_rgba "$start") $(hex_to_rgba "$end") ${angle}deg"
  replace_in_block "general" "col.inactive_border" "$gradient"

  hyprctl reload
}

# --- Other settings (examples) ---
change_gaps() {
  local gaps_in gaps_out
  gaps_in=$(zenity --entry --title="Inner Gaps" --text="Enter gaps_in (px)") || return
  gaps_out=$(zenity --entry --title="Outer Gaps" --text="Enter gaps_out (px)") || return
  replace_in_block "general" "gaps_in" "$gaps_in"
  replace_in_block "general" "gaps_out" "$gaps_out"
  hyprctl reload
}

change_border_width() {
  local val
  val=$(zenity --entry --title="Border Width" --text="Enter width") || return
  replace_in_block "general" "border_size" "$val"
  hyprctl reload
}

# --- Menus ---
window_look_menu() {
  while true; do
    choice=$(zenity --list --title="Window Look & Feel" --column="Option" \
      "Border Gradient" "Border Width" "Gaps" "Back")
    case "$choice" in
    "Border Gradient") change_border_gradient ;;
    "Border Width") change_border_width ;;
    "Gaps") change_gaps ;;
    "Back" | "") break ;;
    esac
  done
}

# --- Main Menu ---
while true; do
  choice=$(zenity --list --title="Hyprland Settings" --column="Category" \
    "Window Look & Feel" "Exit")
  case "$choice" in
  "Window Look & Feel") window_look_menu ;;
  "Exit" | "") exit 0 ;;
  esac
done
