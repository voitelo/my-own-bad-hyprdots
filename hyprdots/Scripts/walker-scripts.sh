#!/usr/bin/env bash

SCRIPT_1="$HOME/test.sh"
SCRIPT_DIR="$HOME/Scripts"

# Collect available scripts
scripts=$(find "$SCRIPT_DIR" -maxdepth 1 -type f -executable -printf "%f\n")

# Build menu
menu=$(printf "%s\n%s\nDelete Script\nCancel" "test.sh" "$scripts")

# Show walker menu
choice=$(echo -e "$menu" | walker --dmenu -c -l 15 -i -p "Run or manage a script:")

# Exit if canceled or empty
[[ -z "$choice" || "$choice" == "Cancel" ]] && exit

# Handle delete mode
if [[ "$choice" == "Delete Script" ]]; then
  # Build delete menu (without "Delete Script"/"Cancel")
  del_menu=$(printf "%s\n%s\nCancel" "test.sh" "$scripts")
  del_choice=$(echo -e "$del_menu" | walker --dmenu -c -l 15 -i -p "Delete which script?")

  [[ -z "$del_choice" || "$del_choice" == "Cancel" ]] && exit

  if [[ "$del_choice" == "test.sh" ]]; then
    rm -r "$SCRIPT_1"
  else
    rm -r "$SCRIPT_DIR/$del_choice"
  fi
  exit
fi

# Run chosen script
if [[ "$choice" == "test.sh" ]]; then
  "$SCRIPT_1"
else
  "$SCRIPT_DIR/$choice"
fi
