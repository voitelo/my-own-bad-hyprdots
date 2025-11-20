#!/bin/bash
# Walker wrapper for menus (dmenu mode)

menu() {
    printf "%s\n" "$@" | fuzzel --dmenu -p "Dashboard >"
}

# Install category search
install_menu() {
    kitty -e ./Scripts/aur-install.sh
}

main_menu() {
    category=$(menu \
        "🎨 Appearance" \
        "⚡ System" \
        "🛠 Utilities" \
        "📊 Stats" \
        "🎮 Gaming" \
        "🔧 Dev Tools" \
        "💾 Files & Storage" \
        "📦 Install" \
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
                "Back"
            )
            case "$choice" in
                "Fastfetch (Kitty)") kitty -e fastfetch ;;
                "Uptime") notify-send "Uptime" "$(uptime -p)" ;;
                "CPU Usage (Kitty top)") kitty -e top --utf-force ;;
                "Memory Usage (Kitty top)") kitty -e top --utf-force ;;
                "Disk Usage") notify-send "Disk Usage" "$(df -h / | awk 'NR==2{print $3\"/\"$2\" used\"}')" ;;
                "Battery Status") notify-send "Battery" "$(cat /sys/class/power_supply/BAT0/capacity)%" ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Gaming ===
        "🎮 Gaming")
            choice=$(menu \
                "Launch Minecraft (Singleplayer)" \
                "Launch Steam" \
                "Launch worst multiplayer game" \
                "Back"
            )
            case "$choice" in
                "Launch Minecraft (Singleplayer)") java -jar /home/leg/Downloads/TLauncher.jar ;;
                "Launch Steam") flatpak run com.valvesoftware.Steam ;;
                "Launch worst multiplayer game") flatpak run org.vinegarhq.Sober ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Dev Tools ===
        "🔧 Dev Tools")
            choice=$(menu \
                "Open Kitty Terminal" \
                "nvim Editor (Kitty)" \
                "Python REPL (Kitty)" \
                "Bash REPL (Kitty)" \
                "Back"
            )
            case "$choice" in
                "Open Kitty Terminal") kitty ;;
                "Micro Editor (Kitty)") kitty -e nvim ;;
                "Python REPL (Kitty)") kitty -e python ;;
                "Bash REPL (Kitty)") kitty -e bash ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Files & Storage ===
        "💾 Files & Storage")
            choice=$(menu \
                "Disk Usage (Kitty ncdu)" \
                "Trash Cleanup" \
                "Back"
            )
            case "$choice" in
                "Disk Usage (Kitty ncdu)") kitty -e ncdu ;;
                "Trash Cleanup") gio trash --empty ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Install ===
        "📦 Install")
            install_menu
            ;;
    esac
}

# Start the menu
main_menu

