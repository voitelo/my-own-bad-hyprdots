#!/usr/bin/env bash
set -euo pipefail

# fuzzel prompt options
OPTIONS=$'caelestia\nDankMaterialShell\nNoctalia\nYahr\nNotTheWorstShell'

CHOICE=$(printf "%b" "$OPTIONS" | fuzzel --dmenu -i -p "pick shell")

case "$CHOICE" in
  caelestia)
     # Kill qs if running
    if pgrep "qs" >/dev/null 2>&1; then
      pkill "qs" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill dms if running
    if pgrep "dms" >/dev/null 2>&1; then
      pkill "dms" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    if pgrep "quickshell" >/dev/null 2>&1; then
      pkill "quickshell" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Launch caelestia shell detached
    setsid caelestia shell >/dev/null 2>&1 &
    qs -c overview & disown >/dev/null 2>&1 &
    ;;

  DankMaterialShell)
    # Kill qs if running
    if pgrep "qs" >/dev/null 2>&1; then
      pkill "qs" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill dms if running
    if pgrep "dms" >/dev/null 2>&1; then
      pkill "dms" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    if pgrep "quickshell" >/dev/null 2>&1; then
      pkill "quickshell" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Launch dms run detached
    setsid dms run >/dev/null 2>&1 &
    qs -c overview & disown >/dev/null 2>&1 &
    ;;

  Noctalia)
    # Kill qs if running
    if pgrep "qs" >/dev/null 2>&1; then
      pkill "qs" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill dms if running
    if pgrep "dms" >/dev/null 2>&1; then
      pkill "dms" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill quickshell if running
    if pgrep "quickshell" >/dev/null 2>&1; then
      pkill "quickshell" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Launch dms run detached
    qs -c ~/.config/quickshell/noctalia/ >/dev/null 2>&1 &
    qs -c overview >/dev/null 2>&1 &
    ;;
 
  Yahr)
    # Kill qs if running
    if pgrep "qs" >/dev/null 2>&1; then
      pkill "qs" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill dms if running
    if pgrep "dms" >/dev/null 2>&1; then
      pkill "dms" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill quickshell if running
    if pgrep "quickshell" >/dev/null 2>&1; then
      pkill "quickshell" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Launch dms run detached
    setsid qs -c ~/.config/quickshell/yahr/ >/dev/null 2>&1 &
    qs -c overview >/dev/null 2>&1 &
    ;;

  NotTheWorstShell)
    # Kill qs if running
    if pgrep "qs" >/dev/null 2>&1; then
      pkill "qs" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill dms if running
    if pgrep "dms" >/dev/null 2>&1; then
      pkill "dms" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Kill quickshell if running
    if pgrep "quickshell" >/dev/null 2>&1; then
      pkill "quickshell" >/dev/null 2>&1 || true
      sleep 0.1
    fi
    # Launch dms run detached
    setsid qs -c ~/.config/quickshell/quickshell/ >/dev/null 2>&1 &
    qs -c overview >/dev/null 2>&1 &
    ;;

  *)
    # nothing chosen or fuzzel closed
    exit 0
    ;;
esac

exit 0

