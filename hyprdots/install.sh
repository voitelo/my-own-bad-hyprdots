#!/bin/env bash

sudo pacman -S git

git clone https://aur.archlinux.org/yay.git
cd yay || exit
makepkg -si
cd || exit

git clone https://github.com/voitelo/my-own-bad-hyprdots
cd my-own-bad-hyprdots/hyprdots || exit
clear

echo "Yy/Nn Do you want to install all packages the creator wants? (recommended unless you want to fumble around)"
read -rsn1 pkgneed
echo
pkgneed=${pkgneed,,}

case $pkgneed in
    y)
      yay -S brightnessctl git fzf caelestia-shell caelestia-cli kitty cosmic-files cosmic-store fish qutebrowser flatpak flameshot localsend neovim rofi jq libxcursor bat eza blueman bluez bluez-utils dms-shell-git fastfetch gammastep grim hyprland hypridle hyprlock hyprpicker imv mpv libnotify mako ttf-cascadia-code-nerd ttf-dejavu ttf-fira-code ttf-monocraft-git wayland wayland-protocols xorg-xwayland swww pipewire pipewire-alsa pipewire-pulse pipewire-jack
      flatpak install -y com.discordapp.Discord
      flatpak install -y com.github.flxzt.rnote
      flatpak install -y com.github.tchx84.Flatseal
      flatpak install -y com.visualstudio.code
      flatpak install -y org.gimp.GIMP
      flatpak install -y org.prismlauncher.PrismLauncher
      ;;
    n)
      echo "you do you, it might not be fun"
      ;;
    *)
      echo "invalid input, run the installer again and remove partially done steps"
      exit
      ;;
esac

clear
echo "y/n (no capitalization) do you want to install my kitty config?"
read -rsn1 kitty
echo
kitty=${kitty,,}

case $kitty in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/.config/kitty ] && mv ~/.config/kitty ~/.config/kitty.bak
        mv kitty ~/.config/kitty
      fi
      ;;
    n)
      echo "ok...."
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to install my nvim config?"
read -rsn1 nvim
echo
nvim=${nvim,,}

case $nvim in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak
        mv nvim ~/.config/nvim
      fi
      ;;
    n)
      echo "ok...."
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to install my fastfetch config?"
read -rsn1 fastfetch
echo
fastfetch=${fastfetch,,}

case $fastfetch in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/.config/fastfetch ] && mv ~/.config/fastfetch ~/.config/fastfetch.bak
        mv fastfetch ~/.config/fastfetch
      fi
      ;;
    n)
      echo "ok...."
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n (this is important) do you want to import my scripts?"
read -rsn1 scripts
echo
scripts=${scripts,,}

case $scripts in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/Scripts ] && mv ~/Scripts ~/Scripts.bak
        mv Scripts ~/Scripts
      fi
      ;;
    n)
      echo "ok.... even with the warning?"
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to import my moosic folder?"
read -rsn1 moosic
echo
moosic=${moosic,,}

case $moosic in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/Moosic ] && mv ~/Moosic ~/Moosic.bak
        mv Moosic ~/Moosic
      fi
      ;;
    n)
      echo "ok...."
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to install my fish config?"
read -rsn1 fish
echo
fish=${fish,,}

case $fish in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/.config/fish ] && mv ~/.config/fish ~/.config/fish.bak
        mv fish ~/.config/fish
      fi
      ;;
    n)
      echo "ok.... user is always right"
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to install my qutebrowser config?"
read -rsn1 qutebrowser
echo
qutebrowser=${qutebrowser,,}

case $qutebrowser in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/.config/qutebrowser ] && mv ~/.config/qutebrowser ~/.config/qutebrowser.bak
        mv qutebrowser ~/.config/qutebrowser
      fi
      ;;
    n)
      echo "ok...."
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to import my utility folder? (just a per theme wallpaper changer)"
read -rsn1 utility
echo
utility=${utility,,}

case $utility in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/.config/utility ] && mv ~/.config/utility ~/.config/utility.bak
        mv utility ~/.config/utility
        echo "fair warning: themes are in a separate repo and may be outdated"
      fi
      ;;
    n)
      echo "ok...."
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to import my hyprland config folder? (important)"
read -rsn1 hypr
echo
hypr=${hypr,,}

case $hypr in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -d ~/.config/hypr ] && mv ~/.config/hypr ~/.config/hypr.bak
        mv hypr ~/.config/hypr
        echo "good choice"
      fi
      ;;
    n)
      echo "ok.... not recommended"
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "y/n do you want to import my bashrc?"
read -rsn1 bash
echo
bash=${bash,,}

case $bash in
    y)
      if [[ $(pwd) == "$HOME/my-own-bad-hyprdots/hyprdots" ]]; then
        [ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
        mv .bashrc ~/.bashrc
      fi
      ;;
    n)
      echo "ok.... can be ignored"
      ;;
    *)
      echo "exiting.. remove the stuff you already did and run again"
      exit
      ;;
esac

clear
echo "Dotfiles installer finished!"

