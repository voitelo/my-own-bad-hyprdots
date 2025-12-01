#!/bin/bash
# fuzzel wrapper for menus (dmenu mode)

menu() {
    printf "%s\n" "$@" | fuzzel --dmenu -p "Dashboard >"
}

app_menu() {
    fuzzel
}

install_menu() {
    install_choice=$(menu \
        "Install webapps" \
        "Install packages (pacman)" \
        "Install AUR packages" \
        "Install game stores" \
        "Back"
    )

    case "$install_choice" in
        "Install webapps")
            kitty -e ~/Scripts/install-webapps.sh
            ;;

        "Install packages (pacman)")
            kitty -e bash -c 'sudo pacman -Slq | fzf --prompt="Pick a pacman package: " | xargs -r sudo pacman -S'
            ;;

        "Install AUR packages")
            kitty -e ./Scripts/aur-install.sh
            ;;

        "Install game stores")
            kitty -e ~/Scripts/install-games.sh
            ;;

        "Back")
            main_menu
            ;;
    esac
}

main_menu() {
    category=$(menu \
        "Apps" \
        "Appearance" \
        "Hyprland configuration" \
        "Install" \
        "Exit"
    )

    [ -z "$category" ] && exit 0
    [ "$category" = "Exit" ] && exit 0

    case "$category" in
        # APPS
        "Apps")
            app_menu
        ;;

        # === Appearance ===
        "Appearance")
            choice=$(menu \
              "Choose a shell (for bar)" \
                "Night Light On" \
                "Night Light Off" \
                "Back"
            )

            case "$choice" in
                "Choose a shell (for bar)") ~/Scripts/choose-bar.sh ;; 
                "Night Light On") gammastep -O 5000 ;;
                "Night Light Off") pkill gammastep && gammastep & ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Hyprland configuration ===
        "Hyprland configuration")
            hyprchoice=$(menu \
                "Main file" \
                "Keybindings" \
                "Monitor" \
                "Animations" \
                "Autostarts" \
                "Cursor" \
                "Input" \
                "Permissions" \
                "Plugins" \
                "Repetitive keybinds" \
                "Variables" \
                "Workspace rules and smart gaps" \
                "Back"
            )

            case "$hyprchoice" in
                "Main file") kitty -e nvim ~/.config/hypr/hyprland.conf ;;
                "Keybindings") kitty -e nvim ~/.config/hypr/sources/keybindings.conf ;;
                "Monitor") kitty -e nvim ~/.config/hypr/hyprland.conf ;;
                "Animations") kitty -e nvim ~/.config/hypr/sources/animations.conf ;;
                "Autostarts") kitty -e nvim ~/.config/hypr/sources/autostart.conf ;;
                "Cursor") kitty -e nvim ~/.config/hypr/sources/cursor.conf ;;
                "Input") kitty -e nvim ~/.config/hypr/sources/input.conf ;;
                "Permissions") kitty -e nvim ~/.config/hypr/sources/permissions.conf ;;
                "Plugins") kitty -e nvim ~/.config/hypr/sources/plugins.conf ;;
                "Repetitive keybinds") kitty -e nvim ~/.config/hypr/sources/repetitive-keybinds.conf ;;
                "Variables") kitty -e nvim ~/.config/hypr/sources/variables.conf ;;
                "Workspace rules and smart gaps") kitty -e nvim ~/.config/hypr/sources/workspace-rulesNsmart-gaps.conf ;;
                "Back") main_menu ;;
            esac
            ;;

        # === Install ===
        "Install")
            install_menu
            ;;
    esac
}

main_menu

