#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/hypr_minimized_windows"
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

# Gather open windows (ignore hidden workspace 9999)
windows=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id != 9999) | "\(.address) \(.workspace.id) \(.title) \(.class)"')

menu=$(printf "%s\n%s\n%s" "Minimize Window" "Un-minimize Window" "Cancel")
choice=$(echo -e "$menu" | walker --dmenu -c -l 10 -i -p "Window Manager:")

[[ -z "$choice" || "$choice" == "Cancel" ]] && exit

if [[ "$choice" == "Minimize Window" ]]; then
  win_choice=$(echo -e "$windows" | awk '{print $1" ["$2"] "$3" ("$4")"}' |
    walker --dmenu -c -l 15 -i -p "Select window to minimize:")

  [[ -z "$win_choice" ]] && exit
  addr=$(echo "$win_choice" | awk '{print $1}')
  ws=$(echo "$windows" | grep "^$addr " | awk '{print $2}')

  # Save state
  if ! grep -q "^$addr " "$STATE_FILE"; then
    echo "$addr $ws" >>"$STATE_FILE"
  fi

  # Move window to hidden workspace 9999 (disappears from hyprctl clients)
  hyprctl dispatch movetoworkspacesilent "9999,address:$addr"
  exit
fi

if [[ "$choice" == "Un-minimize Window" ]]; then
  minimized=$(cat "$STATE_FILE")

  [[ -z "$minimized" ]] && notify-send "HyprMinimize" "No minimized windows." && exit

  # Menu of minimized windows
  unmin_menu=""
  while read -r line; do
    addr=$(echo "$line" | awk '{print $1}')
    ws=$(echo "$line" | awk '{print $2}')
    title=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$addr\") | .title" 2>/dev/null)
    class=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$addr\") | .class" 2>/dev/null)
    unmin_menu+="$addr [$ws] ${title:-Unknown} (${class:-App})\n"
  done <<<"$minimized"

  un_choice=$(echo -e "$unmin_menu" | walker --dmenu -c -l 15 -i -p "Select window to un-minimize:")

  [[ -z "$un_choice" ]] && exit
  addr=$(echo "$un_choice" | awk '{print $1}')
  ws=$(grep "^$addr " "$STATE_FILE" | awk '{print $2}')

  # Restore to original workspace + focus
  hyprctl dispatch movetoworkspacesilent "$ws,address:$addr"
  hyprctl dispatch focuswindow "address:$addr"

  # Remove from state
  grep -v "^$addr " "$STATE_FILE" >"$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
  exit
fi
