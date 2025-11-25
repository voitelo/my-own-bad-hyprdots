#!/usr/bin/env bash
set -e

TIMER_DIR="$HOME/.cache/timers"
CONFIG_FILE="$TIMER_DIR/config"
mkdir -p "$TIMER_DIR"

MAX_TIMERS=5
MIN_DURATION=10
MAX_DURATION=86400
NOTIFY_INTERVAL=20
SOUND_FILE="$HOME/sound_placeholder.wav"

[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

save_settings() {
cat > "$CONFIG_FILE" <<EOL
MAX_TIMERS=$MAX_TIMERS
MIN_DURATION=$MIN_DURATION
MAX_DURATION=$MAX_DURATION
NOTIFY_INTERVAL=$NOTIFY_INTERVAL
SOUND_FILE="$SOUND_FILE"
EOL
}

run_timer_bg() {
    local name="$1"
    local duration="$2"
    local start_epoch=$(date +%s)
    local pid_file="$TIMER_DIR/$name.pid"
    local timer_file="$TIMER_DIR/$name.timer"

    echo "$start_epoch,$duration" > "$timer_file"

    nohup bash -c '
start_epoch='"$start_epoch"'
duration='"$duration"'
timer_file="'"$timer_file"'"
pid_file="'"$pid_file"'"
notify_interval='"$NOTIFY_INTERVAL"'
sound_file="'"$SOUND_FILE"'"

while true; do
    now=$(date +%s)
    remaining=$((duration - (now - start_epoch)))
    ((remaining<=0)) && break

    interval_sec=$((duration * notify_interval / 100))
    ((interval_sec==0)) && interval_sec=1
    if (( (remaining % interval_sec) == 0 )); then
        notify-send "Timer: '"$name"'" "Remaining: $remaining sec"
    fi

    sleep 1
done

paplay "$sound_file" 2>/dev/null || true
notify-send "Timer: '"$name"'" "Time'\''s up!"
rm -f "$pid_file" "$timer_file"
' >/dev/null 2>&1 &

    echo $! > "$pid_file"
}

list_timers() {
    local lines=()
    for file in "$TIMER_DIR"/*.timer; do
        [ -f "$file" ] || continue
        local start_epoch duration
        IFS=',' read -r start_epoch duration < "$file"
        local now=$(date +%s)
        local remaining=$((duration - (now - start_epoch)))
        ((remaining<0)) && remaining=0
        local name=$(basename "$file" .timer)
        lines+=("$name | --> Remaining: $remaining sec")
    done

    [ ${#lines[@]} -eq 0 ] && echo "No timers running." || printf "%s\n" "${lines[@]}"
}

stop_all_timers() {
    for pid_file in "$TIMER_DIR"/*.pid; do
        [ -f "$pid_file" ] || continue
        kill "$(cat "$pid_file")" 2>/dev/null || true
        rm -f "$pid_file"
    done
    rm -f "$TIMER_DIR"/*.timer
    notify-send "Timers" "All timers stopped."
}

settings_panel() {
    while true; do
        choice=$(printf "Max timers: $MAX_TIMERS\nMin duration: $MIN_DURATION\nMax duration: $MAX_DURATION\nNotify interval: $NOTIFY_INTERVAL%%\nSound file: $SOUND_FILE\nBack" | fzf --prompt "Settings> " --height 10 --border)
        case "$choice" in
            Max*) read -rp "Enter max timers: " MAX_TIMERS; save_settings ;;
            Min*) read -rp "Enter min duration: " MIN_DURATION; save_settings ;;
            Max*) read -rp "Enter max duration: " MAX_DURATION; save_settings ;;
            Notify*) read -rp "Enter notify interval (percent): " NOTIFY_INTERVAL; save_settings ;;
            Sound*) read -rp "Enter path to sound file: " SOUND_FILE; save_settings ;;
            Back) break ;;
        esac
    done
}

start_edit_timer() {
    read -rp "Enter timer name: " name
    local pid_file="$TIMER_DIR/$name.pid"
    local timer_file="$TIMER_DIR/$name.timer"

    if [ -f "$timer_file" ]; then
        old_duration=$(cut -d',' -f2 "$timer_file")
        read -rp "Edit duration (sec, current $old_duration): " duration
    else
        read -rp "Enter duration (sec): " duration
    fi

    if [ "$duration" -lt "$MIN_DURATION" ] || [ "$duration" -gt "$MAX_DURATION" ]; then
        echo "Duration out of limits ($MIN_DURATION-$MAX_DURATION)."
        return
    fi

    local running_count=$(ls "$TIMER_DIR"/*.pid 2>/dev/null | wc -l)
    if [ "$running_count" -ge "$MAX_TIMERS" ]; then
        echo "Max timers ($MAX_TIMERS) already running."
        return
    fi

    run_timer_bg "$name" "$duration"
}

while true; do
    choice=$(printf "Start/Edit Timer\nList Timers\nStop All Timers\nSettings\nExit" | fzf --prompt "Timer> " --height 10 --border)
    case "$choice" in
        "Start/Edit Timer") start_edit_timer ;;
        "List Timers") list_timers ;;
        "Stop All Timers") stop_all_timers ;;
        "Settings") settings_panel ;;
        "Exit") exit 0 ;;
    esac
done

