#!/usr/bin/env python3
import os
import shutil
import re

# -------------------------------
# Paths
# -------------------------------
config_path = os.path.expanduser("~/.config/hypr/hyprland.conf")
bak_path = os.path.expanduser("~/Downloads/hyprland.conf.bak")

# -------------------------------
# Backup
# -------------------------------
if os.path.exists(bak_path):
    os.remove(bak_path)
shutil.copy(config_path, bak_path)

# -------------------------------
# Read file
# -------------------------------
with open(config_path, "r") as f:
    lines = f.readlines()

new_lines = []
inside_general = False
last_layout_index = None
last_layout_line = None

# -------------------------------
# Detect general block & layout line
# -------------------------------
for idx, line in enumerate(lines):
    stripped = line.strip()

    # Entering general block
    if stripped.startswith("general"):
        inside_general = True
        new_lines.append(line)
        continue

    # Exiting general block
    if inside_general and stripped.startswith("}"):
        inside_general = False
        # Replace last layout line if found
        if last_layout_index is not None:
            current_layout = last_layout_line.strip().split("=")[1].strip()
            if current_layout == "dwindle":
                new_layout = "master"
            else:
                new_layout = "dwindle"
            new_lines[last_layout_index] = re.sub(r'layout\s*=\s*\w+', f"layout = {new_layout}", lines[last_layout_index])
        new_lines.append(line)
        continue

    # Inside general, track layout line
    if inside_general and stripped.startswith("layout"):
        last_layout_index = idx
        last_layout_line = line

    new_lines.append(line)

# -------------------------------
# Write file if changed
# -------------------------------
if last_layout_index is not None:
    with open(config_path, "w") as f:
        f.writelines(new_lines)
    print(f"Layout toggled successfully! Backup saved to {bak_path}")
else:
    print("No layout line found inside general block.")

