#!/usr/bin/env bash
# rofi-shell-switcher.sh
# Presents three options in rofi:
#  - caelestia        -> kills dms if running, then runs "caelestia shell"
#  - DankMaterialShell -> kills qs if running, then runs "dms run"
#  - Noctalia         -> kills qs if running, then runs "qs -c noctalia-shell"
#
# Uses setsid for safe detachment (like disown).

set -euo pipefail

# rofi prompt options
OPTIONS=$'caelestia\nDankMaterialShell'

CHOICE=$(printf "%b" "$OPTIONS" | rofi -dmenu -i -p "pick shell")

case "$CHOICE" in
  caelestia)
    # Kill dms if running
    if pgrep "dms" >/dev/null 2>&1; then
      pkill "dms" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Launch caelestia shell detached
    setsid caelestia shell >/dev/null 2>&1 &
    ;;

  DankMaterialShell)
    # Kill qs if running
    if pgrep "qs" >/dev/null 2>&1; then
      pkill "qs" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Launch dms run detached
    setsid dms run >/dev/null 2>&1 &
    ;;

  *)
    # nothing chosen or rofi closed
    exit 0
    ;;
esac

exit 0

