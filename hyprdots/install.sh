#!/bin/sh
set -euo pipefail

# Go to home
cd ~

# --- Install yay if missing ---
if ! command -v yay >/dev/null 2>&1; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# --- ASCII blowfish welcome ---
cat <<'EOF'
 ----------------------------------------
< WELCOME TO THE HYPRDOTS INSTALL SCRIPT >
 ----------------------------------------
   \
    \
               |    .
           .   |L  /|
       _ . |\ _| \--+._/| .
      / ||\| Y J  )   / |/| ./
     J  |)'( |        ` F`.'/
   -<|  F         __     .-<
     | /       .-'. `.  /-. L___
     J \      <    \  | | O\|.-'
   _J \  .-    \/ O | | \  |F
  '-F  -<_.     \   .-'  `-' L__
 __J  _   _.     >-'  )._.   |-'
 `-|.'   /_.           \_|   F
   /.-   .                _.<
  /'    /.'             .'  `\
   /L  /'   |/      _.-'-\
  /'J       ___.---'\|
    |\  .--' V  | `. `
    |/`. `-.     `._)
       / .-.\
       \ (  `\
        `.\
EOF

sleep 1

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Optional system update ---
while true; do
    printf "Do you want to update your system before installing packages? (y/n): "
    read update_answer
    case "$update_answer" in
        [Yy]) echo "Updating system..."; sudo pacman -Syu --noconfirm; break ;;
        [Nn]) echo "Skipping system update."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Install packages ---
while true; do
    printf "Do you want to install all needed packages? (y/n): "
    read install_answer
    case "$install_answer" in
        [Yy])
            echo "Installing packages..."
            yay -S bluez hyprlock bluez-utils blueman waybar zen-browser-bin ttf-monocraft-git kitty fastfetch walker-bin wofi flatpak dolphin emote swaybg mpvpaper swaync love minecraft-launcher
            sleep 1
            flatpak install -y org.vinegarhq.Sober com.obsproject.Studio com.github.tchx84.Flatseal
            break ;;
        [Nn]) echo "Skipping package installation."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import Waybar configs ---
while true; do
    printf "Do you want to import Waybar configs to /etc/xdg/waybar? (y/n): "
    read waybar_answer
    case "$waybar_answer" in
        [Yy])
            echo "Copying Waybar configs..."
            sudo cp -r "$SCRIPT_DIR/hyprdots/waybar" /etc/xdg/
            break ;;
        [Nn]) echo "Skipping Waybar configs."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import Kitty config ---
while true; do
    printf "Do you want to import your Kitty config? (y/n): "
    read kitty_answer
    case "$kitty_answer" in
        [Yy])
            echo "Copying Kitty config..."
            mkdir -p ~/.config/kitty
            cp "$SCRIPT_DIR/hyprdots/kitty.conf" ~/.config/kitty/
            break ;;
        [Nn]) echo "Skipping Kitty."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import Custom Apps ---
while true; do
    printf "Do you want to import your custom apps? (y/n): "
    read custom_apps_answer
    case "$custom_apps_answer" in
        [Yy])
            echo "Copying Custom Apps..."
            [ -d ~/Custom-Apps ] && mv ~/Custom-Apps ~/Custom-Apps.backup.$(date +%s)
            cp -r "$SCRIPT_DIR/hyprdots/Custom-Apps" ~
            break ;;
        [Nn]) echo "Skipping Custom Apps."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import Fastfetch config ---
while true; do
    printf "Do you want to import your Fastfetch config? (y/n): "
    read fastfetch_answer
    case "$fastfetch_answer" in
        [Yy])
            echo "Copying Fastfetch config..."
            mkdir -p ~/.config/fastfetch
            cp -r "$SCRIPT_DIR/hyprdots/fastfetch/"* ~/.config/fastfetch/
            break ;;
        [Nn]) echo "Skipping Fastfetch."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import Minecraft instances ---
while true; do
    printf "Do you want to import your Minecraft launcher instances (.minecraft)? (y/n): "
    read minecraft_answer
    case "$minecraft_answer" in
        [Yy])
            echo "Copying .minecraft..."
            [ -d ~/.minecraft ] && mv ~/.minecraft ~/.minecraft.backup.$(date +%s)
            cp -r "$SCRIPT_DIR/hyprdots/.minecraft" ~/
            break ;;
        [Nn]) echo "Skipping Minecraft."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import Hyprland configs ---
while true; do
    printf "Do you want to import Hyprland configs to ~/.config/hypr? (y/n): "
    read hypr_answer
    case "$hypr_answer" in
        [Yy])
            echo "Copying Hyprland configs..."
            mkdir -p ~/.config/hypr
            [ -f ~/.config/hypr/hyprland.conf ] && mv ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.backup.$(date +%s)
            cp -r "$SCRIPT_DIR/hyprdots/hypr/"* ~/.config/hypr/
            break ;;
        [Nn]) echo "Skipping Hyprland configs."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import personal scripts ---
while true; do
    printf "Do you want to copy your personal scripts to ~/Scripts? (y/n): "
    read scripts_answer
    case "$scripts_answer" in
        [Yy])
            echo "Copying scripts..."
            mkdir -p ~/Scripts
            cp -r "$SCRIPT_DIR/hyprdots/Scripts/"* ~/Scripts/
            chmod +x ~/Scripts/*.sh
            break ;;
        [Nn]) echo "Skipping scripts."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Import Lua games ---
while true; do
    printf "Do you want to import Lua games to ~/offline-lua-games? (y/n): "
    read lua_answer
    case "$lua_answer" in
        [Yy])
            echo "Copying Lua games..."
            mkdir -p ~/offline-lua-games
            cp -r "$SCRIPT_DIR/hyprdots/offline-lua-games/"* ~/offline-lua-games/
            break ;;
        [Nn]) echo "Skipping Lua games."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

# --- Optional reload of Waybar and Hyprland ---
while true; do
    printf "Reload Waybar and Hyprland now? (y/n): "
    read reload_answer
    case "$reload_answer" in
        [Yy])
            pkill -USR1 waybar || true
            hyprctl reload || true
            break ;;
        [Nn]) echo "Skipping reload."; break ;;
        *) echo "Please answer y or n." ;;
    esac
done

cat <<'EOF'

 _________________________________
/ Awesome bro, all folders copied \
\ successfully, congratulations!  /
 ---------------------------------
    \                                  ___-------___
     \                             _-~~             ~~-_
      \                         _-~                    /~-_
             /^\__/^\         /~  \                   /    \
           /|  O|| O|        /      \_______________/        \
          | |___||__|      /       /                \          \
          |          \    /      /                    \          \
          |   (_______) /______/                        \_________ \
          |         / /         \                      /            \
           \         \^\\         \                  /               \     /
             \         ||           \______________/      _-_       //\__//
               \       ||------_-~~-_ ------------- \ --/~   ~\    || __/
                 ~-----||====/~     |==================|       |/~~~~~
                  (_(__/  ./     /                    \_\      \.
                         (_(___/                         \_____)_)

EOF

echo "Hyprdots installation complete!"
