#!/bin/bash
# Walker wrapper for menus (dmenu mode)

menu() {
    printf "%s\n" "$@" | walker --dmenu -p "Dashboard >"
}

main_menu() {
    category=$(menu \
        "🎨 Appearance" \
        "⚡ System" \
        "🛠 Utilities" \
        "📊 Stats" \
        "📂 Apps (walker module)" \
        "😊 Emojis (walker module)" \
        "🎮 Gaming" \
        "🔧 Dev Tools" \
        "💾 Files & Storage" \
        "Exit"
    )

    [ -z "$category" ] && exit 0
    [ "$category" = "Exit" ] && exit 0

    case "$category" in
        # === Appearance ===
        "🎨 Appearance")
            choice=$(menu \
                "Toggle Animations" \
                "Toggle Wallpaper" \
                "Toggle Cursor" \
                "Restart Waybar" \
                "Kill Waybar" \
                "Start Waybar" \
                "Reload Hyprland" \
                "Night Light On" \
                "Night Light Off" \
                "Back"
            )
            case "$choice" in
                "Toggle Animations") python ~/Scripts/toggle_animations.sh ;;
                "Toggle Wallpaper") bash ~/Scripts/wallpaper-toggle.sh ;;
                "Toggle Cursor") bash ~/Scripts/cursor-change-only.sh ;;
                "Restart Waybar") pkill waybar && waybar & ;;
                "Kill Waybar") pkill waybar ;;
                "Start Waybar") waybar & ;;
                "Reload Hyprland") hyprctl reload ;;
                "Night Light On") gammastep -O 5000 ;;
                "Night Light Off") pkill gammastep && gammastep & ;;
                "Back") main_menu ;;
            esac
            ;;

        # === System ===
        "⚡ System")
            choice=$(menu \
                "Update & Clean (Kitty)" \
                "Reboot" \
                "Shutdown" \
                "Lock Screen" \
                "Logout" \
                "Suspend" \
                "Swap On (enable)" \
                "Swap Off (disable)" \
                "Clear Notifications" \
                "Back"
            )
            case "$choice" in
                "Update & Clean (Kitty)") kitty -e bash ~/Scripts/updateNclean.sh ;;
                "Reboot") systemctl reboot ;;
                "Shutdown") systemctl poweroff ;;
                "Lock Screen") hyprlock ;;
                "Logout") hyprctl dispatch exit ;;
                "Suspend") systemctl suspend ;;
                "Swap On (enable)") sudo swapon /dev/sda3 ;;
                "Swap Off (disable)") sudo swapoff /dev/sda3 ;;
                "Clear Notifications") dunstctl close-all ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Utilities ===
        "🛠 Utilities")
            choice=$(menu \
                "Sensitivity Toggle" \
                "Alt-Tab Switcher" \
                "Back"
            )
            case "$choice" in
                "Sensitivity Toggle") bash ~/Scripts/sensitivity.sh ;;
                "Alt-Tab Switcher") bash ~/Scripts/alt-tab-switcher.sh ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Stats ===
        "📊 Stats")
            choice=$(menu \
                "Fastfetch (Kitty)" \
                "Uptime" \
                "CPU Usage (Kitty top)" \
                "Memory Usage (Kitty top)" \
                "Disk Usage" \
                "Battery Status" \
                "Network Monitor (Kitty bandwhich)" \
                "Logs (Kitty journalctl -f)" \
                "GPU Usage (Kitty nvtop)" \
                "Sensors (Kitty)" \
                "Back"
            )
            case "$choice" in
                "Fastfetch (Kitty)") kitty -e fastfetch ;;
                "Uptime") notify-send "Uptime" "$(uptime -p)" ;;
                "CPU Usage (Kitty top)") kitty -e top --utf-force ;;
                "Memory Usage (Kitty top)") kitty -e top --utf-force ;;
                "Disk Usage") notify-send "Disk Usage" "$(df -h / | awk 'NR==2{print $3\"/\"$2\" used\"}')" ;;
                "Battery Status") notify-send "Battery" "$(cat /sys/class/power_supply/BAT0/capacity)%" ;;
                "Network Monitor (Kitty bandwhich)") kitty -e bandwhich ;;
                "Logs (Kitty journalctl -f)") kitty -e journalctl -f ;;
                "GPU Usage (Kitty nvtop)") kitty -e nvtop ;;
                "Sensors (Kitty)") kitty -e watch -n2 sensors ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Apps (Walker module) ===
        "📂 Apps (walker module)")
            walker --modules=apps
            ;;

        # === Emojis (Walker module) ===
        "😊 Emojis (walker module)")
            walker --modules=emojis
            ;;

        # === Gaming ===
        "🎮 Gaming")
            choice=$(menu \
                "Launch Minecraft (Singleplayer)" \
                "Launch Minecraft (Multiplayer)" \
                "Launch Steam" \
                "Launch worst multiplayer game" \
                "Back"
            )
            case "$choice" in
                "Launch Minecraft (Singleplayer)") wine ~/Downloads/eby-launcher/Minecraft/LL.exe ;;
                "Launch Minecraft (Multiplayer)") ./Downloads/LabyMod\ Launcher-latest.AppImage ;;
                "Launch Steam") flatpak run com.valvesoftware.Steam ;;
                "Launch worst multiplayer game") flatpak run org.vinegarhq.Sober ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Dev Tools ===
        "🔧 Dev Tools")
            choice=$(menu \
                "Open Kitty Terminal" \
                "Micro Editor (Kitty)" \
                "Python REPL (Kitty)" \
                "Bash REPL (Kitty)" \
                "Love2D Engine" \
                "Back"
            )
            case "$choice" in
                "Open Kitty Terminal") kitty ;;
                "Micro Editor (Kitty)") kitty -e micro ;;
                "Python REPL (Kitty)") kitty -e python ;;
                "Bash REPL (Kitty)") kitty -e bash ;;
                "Love2D Engine") love ~/love-engine/ ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Files & Storage ===
        "💾 Files & Storage")
            choice=$(menu \
                "Disk Usage (Kitty ncdu)" \
                "Mount Drives" \
                "Unmount Drives" \
                "Trash Cleanup" \
                "Back"
            )
            case "$choice" in
                "Disk Usage (Kitty ncdu)") kitty -e ncdu ;;
                "Mount Drives") udisksctl mount -b /dev/sdX ;; # replace sdX
                "Unmount Drives") udisksctl unmount -b /dev/sdX ;; # replace sdX
                "Trash Cleanup") gio trash --empty ;;
                "Back") main_menu ;;
            esac
            ;;
    esac
}

# Start the menu
main_menu
