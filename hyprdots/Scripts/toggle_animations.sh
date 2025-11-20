#!/usr/bin/env python3
import os
import shutil

config_path = os.path.expanduser("~/.config/hypr/hyprland.conf")
bak_path = os.path.expanduser("~/Downloads/hyprland.conf.bak")

# Remove old backup if exists
if os.path.exists(bak_path):
    os.remove(bak_path)

# Create new backup
shutil.copy(config_path, bak_path)

with open(config_path, "r") as f:
    lines = f.readlines()

new_lines = []
inside_animations = False
changed = False

for line in lines:
    stripped = line.strip()

    if stripped.startswith("animations"):
        inside_animations = True
        new_lines.append(line)
        continue

    if inside_animations and stripped.startswith("}"):
        inside_animations = False
        new_lines.append(line)
        continue

    if inside_animations and stripped.startswith("enabled"):
        if "yes" in stripped:
            new_lines.append("    enabled = no\n")
            changed = True
        elif "no" in stripped:
            new_lines.append("    enabled = yes\n")
            changed = True
        else:
            new_lines.append(line)
        continue

    new_lines.append(line)

if changed:
    with open(config_path, "w") as f:
        f.writelines(new_lines)
    print("animations.enabled toggled successfully! Backup saved to ~/Downloads/hyprland.conf.bak")
else:
    print("No animations.enabled line found or nothing to toggle.")
