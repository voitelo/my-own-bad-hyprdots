#!/bin/bash
# ───────────────────────────────
# SpaceMNGR Bash + Yad + Zenity
# ───────────────────────────────

# Dependencies: yad, zenity, kitty, micro

# Config
CURRENT_PATH="$HOME"
HISTORY=("$CURRENT_PATH")
HIST_INDEX=0
RESULT_LIMIT=200

# Color scheme
COLOR_ODD="#F0F0F0"
COLOR_EVEN="#FFFFFF"

# ───────────────────────────────
# Helpers
# ───────────────────────────────

add_history() {
  if [[ "${HISTORY[$HIST_INDEX]}" != "$CURRENT_PATH" ]]; then
    HISTORY+=("$CURRENT_PATH")
    HIST_INDEX=$((${#HISTORY[@]} - 1))
  fi
}

go_back() {
  if ((HIST_INDEX > 0)); then
    HIST_INDEX=$((HIST_INDEX - 1))
    CURRENT_PATH="${HISTORY[$HIST_INDEX]}"
  fi
}

go_forward() {
  if ((HIST_INDEX < ${#HISTORY[@]} - 1)); then
    HIST_INDEX=$((HIST_INDEX + 1))
    CURRENT_PATH="${HISTORY[$HIST_INDEX]}"
  fi
}

list_drives() {
  local drives=("/")
  for base in /mnt /media /run/media; do
    [[ -d $base ]] && drives+=($(ls -1 "$base" 2>/dev/null))
  done
  printf "%s\n" "${drives[@]}"
}

# ───────────────────────────────
# File & Search Logic
# ───────────────────────────────

load_files() {
  local entries=()
  shopt -s nullglob
  for e in "$CURRENT_PATH"/*; do
    [[ -d $e ]] && entries+=("Folder|$e") || entries+=("File|$e")
  done
  shopt -u nullglob
  echo "${entries[@]}"
}

search_files() {
  local query="$1"
  local results=()
  local stop=0

  # Search current directory first
  for entry in "$CURRENT_PATH"/*; do
    [[ $stop -ge $RESULT_LIMIT ]] && break
    [[ -e $entry ]] || continue
    if [[ "${entry,,}" == *"${query,,}"* ]]; then
      [[ -d $entry ]] && results+=("Folder|$entry") || results+=("File|$entry")
      ((stop++))
    fi
  done

  # If nothing, search root recursively (like Python)
  if [[ ${#results[@]} -eq 0 ]]; then
    roots=("/")
    for base in /mnt /media /run/media; do
      [[ -d $base ]] && roots+=("$base")
    done
    for r in "${roots[@]}"; do
      [[ $stop -ge $RESULT_LIMIT ]] && break
      while IFS= read -r f; do
        [[ $stop -ge $RESULT_LIMIT ]] && break
        if [[ "${f,,}" == *"${query,,}"* ]]; then
          [[ -d $f ]] && results+=("Folder|$f") || results+=("File|$f")
          ((stop++))
        fi
      done < <(find "$r" -maxdepth 10 2>/dev/null)
    done
  fi

  echo "${results[@]}"
}

# ───────────────────────────────
# UI
# ───────────────────────────────

show_files() {
  local files=("$@")
  local yad_list=()
  local i=0
  for f in "${files[@]}"; do
    local type="${f%%|*}"
    local path="${f#*|}"
    yad_list+=("$type" "$path")
    ((i++))
  done
  yad --list --title="SpaceMNGR - $CURRENT_PATH" \
    --width=900 --height=600 \
    --column="Type" --column="Path" \
    "${yad_list[@]}"
}

choose_shortcut() {
  local choice
  choice=$(yad --list --title="Shortcuts" --width=400 --height=300 \
    --column="Shortcut" --column="Path" \
    "Home" "$HOME" \
    "Downloads" "$HOME/Downloads" \
    "Documents" "$HOME/Documents" \
    "Desktop" "$HOME/Desktop" \
    "Drives" "drives")

  [[ -z $choice ]] && return
  if [[ $choice == "drives" ]]; then
    local drv=$(list_drives | yad --list --title="Drives" --column="Mount Points")
    [[ -n $drv ]] && CURRENT_PATH="$drv"
  else
    CURRENT_PATH="$choice"
  fi
  add_history
}

context_menu() {
  local action
  action=$(zenity --list --title="Context Menu" --column="Action" \
    "Reload" "Back" "Forward" "Parent Folder" "Shortcuts" "Search")
  case $action in
  "Reload") : ;;
  "Back") go_back ;;
  "Forward") go_forward ;;
  "Parent Folder")
    local parent=$(dirname "$CURRENT_PATH")
    [[ "$parent" != "$CURRENT_PATH" ]] && CURRENT_PATH="$parent" && add_history
    ;;
  "Shortcuts") choose_shortcut ;;
  "Search")
    local query=$(zenity --entry --title="Search" --text="Enter search term:")
    [[ -z $query ]] && return
    mapfile -t results < <(search_files "$query")
    [[ ${#results[@]} -gt 0 ]] && show_files "${results[@]}" || zenity --info --text="No results for '$query'."
    ;;
  esac
}

open_path() {
  local path="$1"
  if [[ -d $path ]]; then
    CURRENT_PATH="$path"
    add_history
  else
    zenity --question --title="Open File" --text="Open '$path' in Kitty + Micro?" && kitty micro "$path" &
  fi
}

# ───────────────────────────────
# Main Loop
# ───────────────────────────────
while true; do
  mapfile -t files < <(load_files)
  [[ ${#files[@]} -eq 0 ]] && files=("Folder|$CURRENT_PATH")
  sel=$(show_files "${files[@]}")
  [[ $? -ne 0 ]] && context_menu && continue
  [[ -z $sel ]] && context_menu && continue
  open_path "$sel"
done
