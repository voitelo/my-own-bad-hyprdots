#!/bin/bash

# Power Menu Script (keymap in hyprland.conf)
# Author: Binoy Manoj
# Modified for single-letter shortcuts

# Options with icons (requires Font Awesome)
shutdown="⏻ Shutdown"
reboot="🔃 Reboot"
suspend="󰒲  Suspend"
lock="🔒 Lock"
logout="↩ Logout"

# Get answer from rofi
selected_option=$(echo -e "$shutdown\n$reboot\n$suspend\n$lock\n$logout" |
  rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/power.rasi)

# Exit if nothing selected
[ -z "$selected_option" ] && exit

# Single-letter shortcut handling + menu selection
case "$selected_option" in
[sS] | "$shutdown") systemctl poweroff ;;
[rR] | "$reboot") systemctl reboot ;;
[dD] | "$suspend") systemctl suspend ;;
[lL] | "$lock") hyprlock ;;
[oO] | "$logout") hyprctl dispatch exit ;;
esac
