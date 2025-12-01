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
run_sudo pacman -Syyu --noconfirm
yay -Syu --noconfirm
yay -Syu --devel --timeupdate
flatpak update -y

# -------------------------------
# Mirror refresh (reflector)
# -------------------------------
if command -v reflector &>/dev/null; then
    log "Refreshing mirrorlist with reflector..."
    run_sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
fi

# -------------------------------
# Orphan packages & cache cleanup
# -------------------------------
warn "Cleaning orphaned packages & caches..."
if command -v orphanrm &>/dev/null; then
    orphanrm -y
else
    log "orphanrm not installed, using pacman/yay fallbacks..."
    run_sudo pacman -Rns --noconfirm $(pacman -Qdtq) || true
    yay -Yc --noconfirm || true
fi

# Pacman & yay caches
run_sudo paccache -r
run_sudo paccache -ruk1
yay -Scc --noconfirm
run_sudo pacman -Scc --noconfirm

# Temp files, thumbnails, logs
warn "Cleaning temp files & logs..."
rm -rf ~/.thumbnails/* ~/.cache/* ~/.local/share/*.log ~/.local/share/Trash/*
run_sudo rm -rf /tmp/* /var/tmp/*
run_sudo rm -rf /var/log/*.old /var/log/*.gz /var/log/*-???????? /var/lib/systemd/coredump/*

# -------------------------------
# Broken symlinks & system cleanup
# -------------------------------
warn "Removing broken symlinks, old locales, package leftovers..."
find $HOME /etc /usr /var -xtype l -delete 2>/dev/null
run_sudo journalctl --vacuum-time=1d
rm -rf ~/.cache/yay/* ~/.cache/thumbnails/* ~/.steam/steam/steamapps/shadercache/* 2>/dev/null
rm -rf ~/.var/app/*/cache/* 2>/dev/null
run_sudo localepurge < /dev/null || true

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
            run_sudo snap remove "$snapname" --revision="$version"
        done
fi
flatpak uninstall --unused -y

# -------------------------------
# Firmware updates
# -------------------------------
if command -v fwupdmgr &> /dev/null; then
    log "Updating firmware..."
    run_sudo fwupdmgr refresh
    run_sudo fwupdmgr update
fi

# -------------------------------
# Intel GPU / OpenGL / Vulkan
# -------------------------------
log "Checking Intel GPU & graphics info..."
command -v glxinfo &>/dev/null && glxinfo | grep "OpenGL"
command -v vulkaninfo &>/dev/null && { echo -e "\n[Vulkan Devices]"; vulkaninfo | grep "VkPhysicalDevice" -A 5; }
run_sudo lshw -c video | grep -i intel

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
# Btrfs maintenance (optional)
# -------------------------------
if gum confirm "Is your root filesystem Btrfs?"; then
    if pacman -Qs btrfs-progs-git &>/dev/null; then
        log "Running safe Btrfs maintenance..."
        run_sudo btrfs scrub start /
        run_sudo btrfs balance start -dusage=50 /
        ok "Btrfs scrub and quick balance started."
    else
        warn "btrfs-progs-git not found. Skipping Btrfs maintenance."
    fi
fi

# -------------------------------
# Optional interactive disk clean
# -------------------------------
if gum confirm "Do you want to use NCDU to clean a few extra files off manually?"; then
    ncdu / --exclude ~/.var/app/
fi

# -------------------------------
# Optional expac / package inspection
# -------------------------------
if command -v expac &>/dev/null; then
    log "Listing largest installed packages..."
    expac -H M '%-30n %15k' | sort -nrk2 | head -20
fi

# -------------------------------
# Optional orphan audit summary
# -------------------------------
if command -v pacman &>/dev/null; then
    log "Listing remaining orphans..."
    pacman -Qdt || ok "No remaining orphans detected."
fi

ok "Maintenance script complete!"

