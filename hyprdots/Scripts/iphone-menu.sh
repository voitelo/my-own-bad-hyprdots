#!/bin/env bash

notify_echo() {
    echo "$1"
    notify-send "$1"
}

pick_directory() {
    find "$HOME" -type d | fuzzel --dmenu --prompt "Select directory:"
}

pick_file() {
    local dir="$1"
    find "$dir" -type f | fuzzel --dmenu --prompt "Pick a file:"
}

enter_text() {
    fuzzel --dmenu --prompt "$1"
}

CHOICE=$(echo "LOCALSEND|Open localsend|Rename files you got sent|Move Downloaded files you got sent|OTHER|Use Uxplay|Quit/Exit" | tr '|' '\n' | fuzzel --dmenu --prompt "Select action:")

[[ -z "$CHOICE" ]] && exit 0

rename_file() {
    dir=$(pick_directory)
    [[ -z "$dir" || ! -d "$dir" ]] && { notify_echo "Directory does not exist."; exit 1; }

    file=$(pick_file "$dir")
    [[ -z "$file" || ! -f "$file" ]] && { notify_echo "That file does not exist."; exit 1; }

    newname=$(enter_text "Enter new name for the file:")
    [[ -z "$newname" ]] && { notify_echo "No name entered."; exit 1; }

    newpath="$(dirname "$file")/$newname"
    [[ -e "$newpath" ]] && { notify_echo "A file with that name already exists."; exit 1; }

    mv "$file" "$newpath" && notify_echo "Renamed to $newname"
}

move_file() {
    dir=$(pick_directory)
    [[ -z "$dir" || ! -d "$dir" ]] && { notify_echo "Directory does not exist."; exit 1; }

    file=$(pick_file "$dir")
    [[ -z "$file" || ! -f "$file" ]] && { notify_echo "That file does not exist."; exit 1; }

    dest=$(pick_directory)
    [[ -z "$dest" || ! -d "$dest" ]] && { notify_echo "Destination directory does not exist."; exit 1; }

    mv "$file" "$dest/" && notify_echo "Moved $(basename "$file") to $dest"
}

case "$CHOICE" in
    "LOCALSEND")
        notify_echo "THIS IS A TITLE NOT AN ACTION"
        ;;
    "Open localsend")
        localsend
        ;;
    "Rename files you got sent")
        rename_file
        ;;
    "Move Downloaded files you got sent")
        move_file
        ;;
    "OTHER")
        notify_echo "THIS IS A TITLE NOT AN ACTION"
        ;;
    "Use Uxplay")
        notify_echo "Launching up uxplay"
        uxplay
        ;;
    "Quit/Exit")
        exit 0
        ;;
esac

