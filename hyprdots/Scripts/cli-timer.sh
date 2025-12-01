#!/bin/bash

clear

# ---- Ask for duration ----
duration=$(gum input --prompt "Enter duration (e.g., 10s, 5m, 1h): ")

# ---- Convert duration to seconds ----
if [[ $duration =~ ^([0-9]+)([hms])$ ]]; then
    value=${BASH_REMATCH[1]}
    unit=${BASH_REMATCH[2]}
    case $unit in
        h) time_in_sec=$((value * 3600)) ;;
        m) time_in_sec=$((value * 60)) ;;
        s) time_in_sec=$((value)) ;;
    esac
else
    echo "Invalid time format."
    exit 1
fi

# ---- Directory path ----
music_dir="/home/dog/Moosic"

# ---- Ask for Minecraft music choice ----
echo
echo "Available Moosic:"
mc_file=$(find "$music_dir" -type f | fzf --prompt "Pick the Minecraft music you want: ")

if [[ ! -f "$mc_file" ]]; then
    echo "That file does not exist."
    exit 1
fi

clear

# ---- Play music in background ----
mpv --no-video --really-quiet --loop "$mc_file" &
MUSIC_PID=$!

# ---- Progress Bar ----
for ((i=0; i<=time_in_sec; i++)); do
    percent=$(( i * 100 / time_in_sec ))
    filled=$(( percent / 2 ))
    empty=$(( 50 - filled ))
    bar=$(printf "%0.s#" $(seq 1 $filled))
    spaces=$(printf "%0.s " $(seq 1 $empty))
    printf "\r[%s%s] %3d%%" "$bar" "$spaces" "$percent"
    sleep 1
done

# ---- Cleanup ----
kill "$MUSIC_PID" 2>/dev/null
clear
echo -e "[##################################################] 100% Done!"

