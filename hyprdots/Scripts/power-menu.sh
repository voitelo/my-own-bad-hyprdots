#!/bin/bash

# Options with icons (requires Font Awesome)
shutdown="⏻ Shutdown"
reboot="🔃 Reboot"
suspend="󰒲  Suspend"
lock="🔒 Lock"
logout="↩ Logout"

# Get answer from fuzzel
selected_option=$(echo -e "$shutdown\n$reboot\n$suspend\n$lock\n$logout" |
  fuzzel --dmenu -i -p "Power Menu" )

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
