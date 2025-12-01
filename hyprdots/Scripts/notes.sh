#!/usr/bin/env bash

folder="$HOME/notes/"
mkdir -p "$folder"

open_note() {
  local file="$1"

  if [ -t 1 ]; then
    nvim "$file"
  else
    setsid -f kitty -e nvim "$file" >/dev/null 2>&1
  fi
}

generate_default_name() {
  local i=1
  while [[ -f "$folder/default$i.txt" ]]; do
    ((i++))
  done
  echo "default$i.txt"
}

newnote() {
  default_name=$(generate_default_name)
  name="$(echo "$default_name" | fuzzel --dmenu -p "Enter note name:")"
  [[ -z "$name" ]] && return
  [[ "$name" != *.txt ]] && name="$name.txt"
  file="$folder$name"
  [ ! -f "$file" ] && touch "$file"
  open_note "$file"
}

delete_note() {
  notes=$(ls -t1 "$folder")
  [[ -z "$notes" ]] && return
  file_to_delete=$(echo -e "$notes" | fuzzel --dmenu -p "Select note to delete:")
  [[ -z "$file_to_delete" ]] && return
  rm -r "$folder$file_to_delete"
}

selected() {
  notes=$(lsd "$folder")
  # Menu order: Create note -> existing notes -> Delete note -> Cancel
  menu=$(printf "Create note\n%s\nDelete note\nCancel" "$notes")
  choice=$(echo -e "$menu" | fuzzel --dmenu -p "Select or type note:")

  [[ -z "$choice" || "$choice" == "Cancel" ]] && exit

  case "$choice" in
  "Create note") newnote ;;
  "Delete note") delete_note ;;
  *)
    # Open or create typed/existing note
    file="$folder$choice"
    [[ ! -f "$file" && "$file" != *.txt ]] && file="$file.txt"
    [ ! -f "$file" ] && touch "$file"
    open_note "$file"
    ;;
  esac
}

selected

