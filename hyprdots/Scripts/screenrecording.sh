#!/bin/bash

PID=""

CHOICE=$(echo "Record fullscreen with audio|Record region with audio|Record fullscreen no audio|Record region no audio|Timed fullscreen with audio|Timed region with audio|Record app with audio|Stop recording|Exit" | tr '|' '\n' | fuzzel --dmenu --prompt "Select action:")

[[ -z "$CHOICE" ]] && exit 0

DATE=$(date '+%Y-%m-%d_%H-%M-%S')
OUTPUT=~/Videos/"$DATE".mp4

case "$CHOICE" in
    "Record fullscreen with audio")
        gpu-screen-recorder -encoder cpu -w screen -o "$OUTPUT" &
        PID=$!
        ;;
    "Record region with audio")
        REGION=$(slurp -f "%wx%h+%x+%y")
        gpu-screen-recorder -encoder cpu -w region -region "$REGION" -o "$OUTPUT" &
        PID=$!
        ;;
    "Record fullscreen no audio")
        gpu-screen-recorder -encoder cpu -w screen -o "$OUTPUT" &
        PID=$!
        ;;
    "Record region no audio")
        REGION=$(slurp -f "%wx%h+%x+%y")
        gpu-screen-recorder -encoder cpu -w region -region "$REGION" -o "$OUTPUT" &
        PID=$!
        ;;
    "Timed fullscreen with audio")
        DURATION=$(fuzzel --dmenu --prompt "Enter duration in seconds:")
        gpu-screen-recorder -encoder cpu -w screen -o "$OUTPUT" &
        PID=$!
        sleep "$DURATION"
        kill $PID
        ;;
    "Timed region with audio")
        DURATION=$(fuzzel --dmenu --prompt "Enter duration in seconds:")
        REGION=$(slurp -f "%wx%h+%x+%y")
        gpu-screen-recorder -encoder cpu -w region -region "$REGION" -o "$OUTPUT" &
        PID=$!
        sleep "$DURATION"
        kill $PID
        ;;
    "Record app with audio")
        APP=$(fuzzel --dmenu --prompt "Enter app name:")
        gpu-screen-recorder -encoder cpu -w focus -o "$OUTPUT" &
        PID=$!
        ;;
    "Stop recording")
        killall gpu-screen-recorder
        ;;
    "Exit")
        exit 0
        ;;
esac

