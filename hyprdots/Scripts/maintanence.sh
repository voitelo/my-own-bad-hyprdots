#!/bin/bash

# -------------------------------
# Colors
# -------------------------------
RESET="\033[0m"
INFO="\033[1;34m"
WARN="\033[1;33m"
OK="\033[1;32m"
ROOT="\033[1;31m"

# -------------------------------
# Helper Functions
# -------------------------------
log() { echo -e "${INFO}[INFO]${RESET} $1"; }
warn() { echo -e "${WARN}[WARN]${RESET} $1"; }
ok()   { echo -e "${OK}[OK]${RESET} $1"; }

run_sudo() {
    if [ "$EUID" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# -------------------------------
# Banner
# -------------------------------
cat << 'EOF'

 ------------------------------------
 < Welcome To Arch Maintenance >
 ------------------------------------
     \
      \


          oO)-.                       .-(Oo
         /__  _\                     /_  __\
         \  \(  |     ()~()         |  )/  /
          \__|\ |    (-___-)        | /|__/
          '  '--'    ==`-'==        '--'  '

EOF

# -------------------------------
# System Update
# -------------------------------
log "Updating system..."
sudo pacman -Syyu --noconfirm
yay -Syu --noconfirm
yay -Syu --devel --timeupdate
flatpak update -y

# Call external script if exists
[ -f "$HOME/Scripts/mean-PM.sh" ] && bash "$HOME/Scripts/mean-PM.sh" -Syu

# -------------------------------
# Orphan packages & cache cleanup
# -------------------------------
warn "Cleaning orphaned packages, caches, tmp, thumbnails, logs..."
sudo pacman -Rns --noconfirm $(pacman -Qdtq) || true
yay -Yc --noconfirm || true
for i in {1..5}; do
    yay -Rns --noconfirm $(yay -Qdtqdtdtdtdtdt) || true
done

for i in {1..5}; do
    yay -Rns --noconfirm $(yay -Qdtqdt) && yay -Yc
done

# Pacman & yay caches
sudo paccache -r
sudo paccache -ruk1
yay -Scc
sudo pacman -Scc

# Temp files, thumbnails, logs
sudo rm -rf ~/.thumbnails/* ~/.cache/* ~/.local/share/*.log ~/.local/share/Trash/*
sudo rm -rf /tmp/* /var/tmp/*
sudo rm -rf /var/log/*.old /var/log/*.gz /var/log/*-???????? /var/lib/systemd/coredump/*

# -------------------------------
# Extra system cleanup
# -------------------------------
warn "Removing broken symlinks, old locales, package build leftovers..."
find $HOME /etc /usr /var -xtype l -delete 2>/dev/null
sudo journalctl --vacuum-time=1d
rm -rf ~/.cache/yay/* ~/.cache/thumbnails/* ~/.steam/steam/steamapps/shadercache/* 2>/dev/null
rm -rf ~/.var/app/*/cache/* 2>/dev/null
sudo localepurge < /dev/null || true

# -------------------------------
# Node / Python / package caches
# -------------------------------
warn "Cleaning dev caches..."
rm -rf ~/.npm ~/.npm-cache ~/.cache/yarn ~/.cache/pip
pip cache purge || true

# -------------------------------
# Snap / Flatpak cleanup
# -------------------------------
if command -v snap &>/dev/null; then
    log "Cleaning old snap revisions..."
    snap list --all | awk '/disabled/{print $1, $2}' |
        while read snapname version; do
            sudo snap remove "$snapname" --revision="$version"
        done
fi
flatpak uninstall --unused -y

# -------------------------------
# Firmware updates
# -------------------------------
if command -v fwupdmgr &> /dev/null; then
    log "Updating firmware..."
    sudo fwupdmgr refresh
    sudo fwupdmgr update
fi

# -------------------------------
# Intel GPU / OpenGL / Vulkan
# -------------------------------
log "Checking Intel GPU & graphics info..."
command -v glxinfo &>/dev/null && glxinfo | grep "OpenGL"
command -v vulkaninfo &>/dev/null && { echo -e "\n[Vulkan Devices]"; vulkaninfo | grep "VkPhysicalDevice" -A 5; }
sudo lshw -c video | grep -i intel

# -------------------------------
# Hyprland tweaks
# -------------------------------
log "Reloading Hyprland configs..."
hyprctl reload
hyprpm update
hyprpm reload -n

# -------------------------------
# GTK / font / icon caches
# -------------------------------
log "Refreshing GTK, icon, and font caches..."
fc-cache -rv
gtk-update-icon-cache
update-icon-caches /usr/share/icons/*

# -------------------------------
# Boot analysis & systemd health
# -------------------------------
log "Analyzing boot & system health..."
systemctl daemon-reexec
systemctl reset-failed
systemctl --failed
systemd-analyze blame | head -20
systemd-analyze critical-chain
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -20

# -------------------------------
# Optional GRUB update
# -------------------------------
# sudo grub-mkconfig -o /boot/grub/grub.cfg

# -------------------------------
# GDU
# -------------------------------
printf "Do you want to use GDU to clean a few extra files off manually? Y/y/N/n: "
read gdu_question
case "$gdu_question" in
  [Yy])
      echo "Running gdu..."
      gdu /
      ;;
  [Nn])
      echo "Skipping gdu."
      ;;
  *)
      echo "Invalid input. Skipping gdu."
      ;;
esac
