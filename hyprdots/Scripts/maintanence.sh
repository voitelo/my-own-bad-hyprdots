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
sudo pacman -Rns $(pacman -Qdtq) --noconfirm
yay -Yc --noconfirm
sudo paccache -r
sudo paccache -ruk1
yay -Scc --noconfirm
sudo pacman -Scc --noconfirm
rm -rf ~/.thumbnails/* ~/.cache/* ~/.local/share/*.log
sudo rm -rf /tmp/* /var/tmp/*
sudo rm -rf /var/log/*.old /var/log/*.gz

# -------------------------------
# Extra useless crap cleanup
# -------------------------------

echo -e "${WARN}Hunting extra useless crap...${RESET}"

# Remove broken symlinks (orphans in $HOME, /etc, /usr)
find $HOME /etc /usr -xtype l -delete 2>/dev/null

# Clear systemd journal logs (keeps last week only)
sudo journalctl --vacuum-time=7d

# Remove leftover package build dirs (yay cache, etc)
rm -rf ~/.cache/yay/*

# Remove old core dumps (if any)
sudo rm -rf /var/lib/systemd/coredump/*

# Wipe thumbnails, Steam shader cache bloat
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.steam/steam/steamapps/shadercache/* 2>/dev/null
rm -rf ~/.var/app/*/cache/* 2>/dev/null

# Clean unused locales (only keep en + system lang)
sudo localepurge < /dev/null || true


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

# ------------------------
# grub shit 
# ------------------------

# sudo update-grub
# sudo grub-mkconfig -o /boot/grub/grub.cfg

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
