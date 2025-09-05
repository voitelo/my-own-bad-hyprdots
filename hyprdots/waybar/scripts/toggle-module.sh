#!/bin/bash

MODULE=$1
STATE_FILE="/tmp/waybar-${MODULE}-visible"

if [[ -f "$STATE_FILE" ]]; then
  rm "$STATE_FILE"
else
  touch "$STATE_FILE"
fi

pkill -SIGUSR2 waybar
