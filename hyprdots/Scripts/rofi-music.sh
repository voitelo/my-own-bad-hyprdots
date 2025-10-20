#!/usr/bin/env bash

music_dir="$HOME/Moosic"

open_player() {
  local file="$1"
  if [ -t 1 ]; then
    # Interactive terminal, play directly
    mpv "$file"
  else
    # Launched via keybind, open in kitty
    setsid -f kitty -e mpv "$file" >/dev/null 2>&1
  fi
}

# Find all mp3 and ogg files
tracks=$(find "$music_dir" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.ogg" \) -printf "%f\n")

# Add Cancel option at the bottom
menu=$(printf "%s\nCancel" "$tracks")

# Show menu with rofi
choice=$(echo -e "$menu" | rofi -dmenu -p "Select track to play:")

# Exit if canceled or empty
[[ -z "$choice" || "$choice" == "Cancel" ]] && exit

# Play the selected track
file="$music_dir/$choice"
[ -f "$file" ] && open_player "$file"

