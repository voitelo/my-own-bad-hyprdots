#!/bin/bash

# --- Colors ---
RESET="\033[0m"
INFO="\033[1;34m"
WARN="\033[1;33m"
OK="\033[1;32m"
ROOT="\033[1;31m"

cat <<EOF

 ------------------------------------
 < Welcome To The Arch Maintenance Beast >
 ------------------------------------
     \
      \


          oO)-.                       .-(Oo
         /__  _\                     /_  __\
         \  \(  |     ()~()         |  )/  /
          \__|\ |    (-___-)        | /|__/
          '  '--'    ==\`-'==        '--'  '

EOF

# -------------------------------
# Ask about yay
# -------------------------------

echo -e "${INFO}Do you want to use yay with this? (yes/no): ${RESET}"
read ANSWER

if [ "$ANSWER" != "yes" ]; then
    echo -e "${WARN}Sorry idiot, you gotta use yay, it's part of this script.${RESET}"
    exit 0
fi

echo -e "${INFO}Proceeding with yay...${RESET}"

# -------------------------------
# Update system
# -------------------------------

echo -e "${WARN}Updating system...${RESET}"
sudo pacman -Syyu --noconfirm
yay -Syu --noconfirm
yay -Syu --devel --timeupdate
flatpak update -y

# Direct call to mean-PM.sh
if [ -f "$HOME/Scripts/mean-PM.sh" ]; then
    bash "$HOME/Scripts/mean-PM.sh" -Syu
fi

# -------------------------------
# Orphan packages & cache cleanup
# -------------------------------

echo -e "${WARN}Cleaning orphaned packages, caches, tmp, thumbnails, logs...${RESET}"
sudo pacman -Rns $(pacman -Qdtq) --noconfirm || true
yay -Yc --noconfirm || true
sudo paccache -r
sudo paccache -ruk1
yay -Scc --noconfirm
sudo pacman -Scc --noconfirm
rm -rf ~/.thumbnails/* ~/.cache/* ~/.local/share/*.log
sudo rm -rf /tmp/* /var/tmp/*
sudo rm -rf /var/log/*.old /var/log/*.gz

# -------------------------------
# Kernel cleanup (linux-zen)
# -------------------------------

echo -e "${INFO}Cleaning old linux-zen kernels...${RESET}"
sudo pacman -Rns $(pacman -Qq | grep '^linux-zen-[0-9]*' | grep -v $(uname -r)) || true
sudo pacman -Rns $(pacman -Qq | grep '^linux-zen-headers-[0-9]*' | grep -v $(uname -r)) || true
sudo depmod -a

# -------------------------------
# Firmware updates
# -------------------------------

if command -v fwupdmgr &> /dev/null; then
    echo -e "${INFO}Updating firmware...${RESET}"
    sudo fwupdmgr refresh
    sudo fwupdmgr update
fi

# -------------------------------
# Intel GPU / OpenGL / Vulkan
# -------------------------------

echo -e "${INFO}Checking Intel GPU & graphics info...${RESET}"
if command -v glxinfo &>/dev/null; then glxinfo | grep "OpenGL"; fi
if command -v vulkaninfo &>/dev/null; then
    echo -e "\n[Vulkan Devices]"
    vulkaninfo | grep "VkPhysicalDevice" -A 5
fi
sudo lshw -c video | grep -i intel

# -------------------------------
# Hyprland tweaks
# -------------------------------

echo -e "${INFO}Reloading Hyprland configs...${RESET}"
hyprctl reload
hyprctl dispatch dpms off
sleep 1
hyprctl dispatch dpms on
hyprpm update
hyprpm reload -r

# -------------------------------
# GTK / font / icon caches
# -------------------------------

echo -e "${INFO}Refreshing GTK, icon, and font caches...${RESET}"
fc-cache -rv
gtk-update-icon-cache
update-icon-caches /usr/share/icons/*

# -------------------------------
# Boot analysis & systemd health
# -------------------------------

echo -e "${INFO}Analyzing boot & system health...${RESET}"
systemctl daemon-reexec
systemctl reset-failed
systemctl --failed
systemd-analyze blame | head -20
systemd-analyze critical-chain
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -20

# -------------------------------
# Snap / Ubuntu leftovers removal
# -------------------------------

sudo pacman -Rns snapd --noconfirm 2>/dev/null || true
rm -rf ~/snap

# -------------------------------
# ncdu / question (last)
# -------------------------------

echo -e "${INFO}Do you want to use ncdu / --exclude /home/$USER/.var/app/com.valvesoftware.Steam? (Y/N): ${RESET}"
read NCDU

if [[ "$NCDU" =~ ^[Nn]$ ]]; then
    echo -e "${WARN}Aight no ncdu then idiot.${RESET}"
    exit 0
else
    ncdu / --exclude ~/.var/app/com.valvesoftware.Steam
fi
