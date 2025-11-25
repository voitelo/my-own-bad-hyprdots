#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# Hyprland Screenshot + Color Picker with settings
# -------------------------------

CACHE_FILE="${HOME}/.cache/screenshotNpicker-cache.txt"
mkdir -p "$(dirname "$CACHE_FILE")"

# Default settings
POST_MENU=1           # 1=show second menu after action, 0=skip
MENU_PROGRAM=wmenu     # wmenu or fuzzel
MODULES="color,full,window,select"

# Load settings if file exists
if [[ -f "$CACHE_FILE" ]]; then
    source "$CACHE_FILE"
fi

save_settings(){
    cat > "$CACHE_FILE" <<EOF
POST_MENU=$POST_MENU
MENU_PROGRAM=$MENU_PROGRAM
MODULES="$MODULES"
EOF
    notify-send "Screenshot script settings saved."
}

OUTDIR="${HOME}/Screenshots"; mkdir -p "$OUTDIR"
NOTIFYCMD=$(command -v dunstify 2>/dev/null || command -v notify-send)
CLIPHIST=$(command -v cliphist || true)
MAGICK=$(command -v magick || true)
WMENU=$(command -v "$MENU_PROGRAM" || { echo "Missing menu program"; exit 1; })

# -------------------------------
# Core functions
# -------------------------------

post(){ 
    [[ "${WATERMARK:-}" == "1" && -n "$MAGICK" ]] && { 
        magick "$FILE" \
            -gravity "${WATERMARK_POS:-southeast}" \
            -pointsize "${WATERMARK_SIZE:-28}" \
            -fill white -undercolor "${WATERMARK_BG:-#00000080}" \
            -annotate +20+20 "${WATERMARK_TEXT:-$(date '+%Y-%m-%d %H:%M')}" \
            "$FILE"
    }

    wl-copy --type=image/png < "$FILE"
    $NOTIFYCMD -i "$FILE" "Screenshot saved: $(basename "$FILE")"
    [[ -n "$CLIPHIST" ]] && $CLIPHIST store "$FILE"
}

capture_full(){ 
    flameshot gui -p "$OUTDIR"
    FILE=$(ls -t "$OUTDIR"/*.png | head -n1)
    post
}

capture_window(){ 
    flameshot gui -p "$OUTDIR"
    FILE=$(ls -t "$OUTDIR"/*.png | head -n1)
    post
}

capture_selection(){ 
    flameshot gui -p "$OUTDIR"
    FILE=$(ls -t "$OUTDIR"/*.png | head -n1)
    post
}

colorpicker(){ 
    command -v hyprpicker &>/dev/null || { $NOTIFYCMD "Missing: hyprpicker"; exit 1; }
    hex=$(hyprpicker)
    echo "$hex" | wl-copy
    $NOTIFYCMD "Picked color: $hex"
}

# -------------------------------
# Menu functions
# -------------------------------

settings_menu(){
    CHOICE=$(
        printf "Toggle post-action menu\nSet menu program\nSet available modules\nReset to defaults" | "$WMENU" -l 4 -p "Settings: "
    )
    case "$CHOICE" in
        *Toggle*)
            POST_MENU=$((1-POST_MENU))
            save_settings
            ;;
        *program*) 
            NEW=$(printf "wmenu\nfuzzel" | "$WMENU" -l 2 -p "Choose menu program: ")
            [[ -n "$NEW" ]] && MENU_PROGRAM="$NEW" && save_settings
            ;;
        *modules*) 
            NEW=$(echo "$MODULES" | "$WMENU" -p "Modules (comma-separated): ")
            [[ -n "$NEW" ]] && MODULES="$NEW" && save_settings
            ;;
        *Reset*)
            POST_MENU=1
            MENU_PROGRAM=wmenu
            MODULES="color,full,window,select"
            save_settings
            ;;
    esac
}

main(){ 
    # Build menu options from MODULES and add settings
    OPTIONS=$(echo "$MODULES" | tr ',' '\n')
    OPTIONS="$OPTIONS"$'\n'"settings"

    MODE=$(
        printf "%s\n" "$OPTIONS" | "$WMENU" -l 5 -p "Capture mode: "
    )

    # Sleep only if there is no second menu
    [[ "$POST_MENU" -eq 0 ]] && sleep 0.8

    case "$MODE" in
        color) colorpicker ;;
        full) capture_full ;;
        window) capture_window ;;
        select) capture_selection ;;
        settings) settings_menu ;;
        *) exit 0 ;;
    esac

    # Optional second menu after action
    if [[ "$POST_MENU" -eq 1 ]]; then
        POST_CHOICE=$(
            printf "Open selection menu\nDo nothing" | "$WMENU" -l 2 -p "After action: "
        )
        sleep 0.8
        case "$POST_CHOICE" in
            *Open*) capture_selection ;;
            *nothing*) ;;
        esac
    fi
}

main

