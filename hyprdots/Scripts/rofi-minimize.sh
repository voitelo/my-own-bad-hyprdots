#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/hypr_minimized_windows"
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

# Gather open windows (ignore hidden workspace 9999)
windows=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id != 9999) | "\(.address) \(.workspace.id) \(.title|gsub("\n";" ")) \(.class)"')

# Main menu
menu="Minimize Window\nUn-minimize Window\nCancel"
choice=$(echo -e "$menu" | rofi -dmenu -p "Window Manager:")

[[ -z "$choice" || "$choice" == "Cancel" ]] && exit

# -----------------------
# Minimize flow
# -----------------------
if [[ "$choice" == "Minimize Window" ]]; then
  # Build list of windows for selection
  win_list=$(echo "$windows" | awk '{addr=$1; ws=$2; $1=$2=""; title_class=$0; print addr " [" ws "] " title_class}')
  win_choice=$(echo -e "$win_list" | rofi -dmenu -p "Select window to minimize:")
  
  [[ -z "$win_choice" ]] && exit

  addr=$(echo "$win_choice" | awk '{print $1}')
  ws=$(echo "$windows" | grep "^$addr " | awk '{print $2}')

  # Save to state file if not already present
  if ! grep -q "^$addr " "$STATE_FILE"; then
    echo "$addr $ws" >> "$STATE_FILE"
  fi

  # Move window to hidden workspace 9999
  hyprctl dispatch movetoworkspacesilent "9999,address:$addr"
  exit
fi

# -----------------------
# Un-minimize flow
# -----------------------
if [[ "$choice" == "Un-minimize Window" ]]; then
  minimized=$(cat "$STATE_FILE")
  [[ -z "$minimized" ]] && notify-send "HyprMinimize" "No minimized windows." && exit

  # Build menu of minimized windows
  unmin_menu=""
  while read -r line; do
    addr=$(echo "$line" | awk '{print $1}')
    ws=$(echo "$line" | awk '{print $2}')
    client=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$addr\")")
    title=$(echo "$client" | jq -r '.title // "Unknown"' 2>/dev/null)
    class=$(echo "$client" | jq -r '.class // "App"' 2>/dev/null)
    unmin_menu+="$addr [$ws] $title ($class)\n"
  done <<< "$minimized"

  un_choice=$(echo -e "$unmin_menu" | rofi -dmenu -p "Select window to un-minimize:")
  [[ -z "$un_choice" ]] && exit

  addr=$(echo "$un_choice" | awk '{print $1}')
  ws=$(grep "^$addr " "$STATE_FILE" | awk '{print $2}')

  # Restore window
  hyprctl dispatch movetoworkspacesilent "$ws,address:$addr"
  hyprctl dispatch focuswindow "address:$addr"

  # Remove from state file
  grep -v "^$addr " "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  exit
fi

