#!/usr/bin/env python3
import subprocess
import time
import os
from datetime import datetime, timedelta

# ====== CONFIG ======
OUTPUT_FILE = "package-log.txt"  # <-- your file path
PACMAN_LOG = "/var/log/pacman.log"
CHECK_INTERVAL = 5  # seconds between checks
DAYS_UNUSED = 7
# =====================

# These are considered "core" packages that every Arch system has or needs.
# You can add or remove items freely.
ESSENTIAL_PACKAGES = {
    "base", "base-devel", "linux", "linux-firmware",
    "glibc", "bash", "fish", "coreutils", "filesystem", "util-linux",
    "pacman", "sed", "grep", "gawk", "findutils", "gzip",
    "sudo", "wayland", "wayland-protocols",
    "systemd", "systemd-libs", "flatpak", "dbus", "bash-completion",
    "shadow", "procps-ng", "e2fsprogs", "less", "iproute2",
    "inetutils", "kbd", "kmod", "nvim",
    "gcc-libs", "readline", "tzdata", "iwd", "networkmanager",
    "hyprland", "xdg-desktop-portal", "xdg-desktop-portal-hyprland"
}

def run(cmd):
    return subprocess.getoutput(cmd).strip()

def get_installed_packages():
    pkgs = set(run("pacman -Qq").splitlines())
    return {p for p in pkgs if p not in ESSENTIAL_PACKAGES}

def detect_non_pacman_packages():
    tracked_files = set(run("pacman -Qlq").splitlines())
    system_bins = {"/usr/bin/" + f for f in os.listdir("/usr/bin")}
    return {os.path.basename(f) for f in system_bins if f not in tracked_files}

def find_unused_packages(days_old=DAYS_UNUSED):
    result = set()
    now = datetime.now()
    try:
        with open(PACMAN_LOG, "r", errors="ignore") as log:
            for line in log:
                if "installed" in line or "upgraded" in line:
                    parts = line.strip().split()
                    date_str = " ".join(parts[0:2]).strip("[]")
                    pkg = parts[-1].split(":")[0]
                    try:
                        log_date = datetime.strptime(date_str, "%Y-%m-%d %H:%M")
                        if (now - log_date) > timedelta(days=days_old) and pkg not in ESSENTIAL_PACKAGES:
                            result.add(pkg)
                    except Exception:
                        continue
    except FileNotFoundError:
        pass
    return result

def write_report(installed, non_pacman, unused):
    with open(OUTPUT_FILE, "w") as f:
        f.write("----- Pacman -Q packages ----\n\n")
        for pkg in sorted(installed):
            f.write(f"{pkg}\n")

        f.write("\n--- packages not detected by pacman -Q ---\n\n")
        for pkg in sorted(non_pacman):
            f.write(f"{pkg}\n")

        f.write("\n--- useless but non orphaned packages ---\n\n")
        for pkg in sorted(unused):
            f.write(f"{pkg}\n")
        f.flush()
        os.fsync(f.fileno())

def regenerate_report():
    installed = get_installed_packages()
    non_pacman = detect_non_pacman_packages()
    unused = find_unused_packages()
    write_report(installed, non_pacman, unused)

def main():
    print("📦 Pacman watcher running (filtered)... Press Ctrl+C to stop.")
    last_mtime = 0
    regenerate_report()
    while True:
        try:
            mtime = os.path.getmtime(PACMAN_LOG)
            if mtime != last_mtime:
                print("🔄 Detected pacman change, updating report...")
                regenerate_report()
                last_mtime = mtime
            time.sleep(CHECK_INTERVAL)
        except KeyboardInterrupt:
            print("\n🛑 Exiting watcher.")
            break
        except Exception as e:
            print(f"⚠️ Error: {e}")
            time.sleep(10)

if __name__ == "__main__":
    main()

