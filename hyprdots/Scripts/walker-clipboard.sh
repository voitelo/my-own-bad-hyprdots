#!/usr/bin/env bash

histfile="$HOME/.local/share/cliphist_walker"
mkdir -p "$(dirname "$histfile")"
[ -f "$histfile" ] || touch "$histfile"

# Add a single-line entry to history if not duplicate
add_to_history() {
  local line="$1"
  [[ -z "$line" || "$line" == *$'\n'* ]] && return
  grep -Fxq "$line" "$histfile" || echo "$line" >>"$histfile"
}

# On first run, try to populate history from current clipboard
clip=$(wl-paste -n 2>/dev/null)
add_to_history "$clip"

# Build menu: create "Delete entry" option if needed
menu=$(printf "%s\nDelete entry\nCancel" "$(tac "$histfile")")

# Show walker menu
choice=$(echo -e "$menu" | walker --dmenu -c -l 12 -i -p "Clipboard history (or type new): ")

[[ -z "$choice" || "$choice" == "Cancel" ]] && exit

case "$choice" in
"Delete entry")
  # Select entry to delete
  del=$(tac "$histfile" | walker --dmenu -c -l 10 -i -p "Select entry to delete:")
  [[ -n "$del" ]] && sed -i "\|$del|d" "$histfile" && notify-send -t 3000 "Deleted: $del"
  ;;
*)
  # Copy typed or selected text to clipboard
  echo -n "$choice" | wl-copy
  add_to_history "$choice"
  notify-send -t 3000 "Copied to clipboard: $choice"
  ;;
esac
