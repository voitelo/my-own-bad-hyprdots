#!/usr/bin/env python3
import sys
import tkinter as tk
from tkinter import messagebox

# === Configuration ===
BAR_LENGTH_CLI = 80
BAR_LENGTH_GUI = 600
BAR_HEIGHT = 40
MAX_PACKAGES = 2000
MAX_FLATPAKS = 50

PACKAGE_GUI_COLORS = ["green","yellow","orange","red","magenta","purple","white"]
FLATPAK_GUI_COLORS = ["green","yellow","orange","red","magenta","purple"]
RESET = "\033[0m"
PACKAGE_CLI_COLORS = ["\033[42m","\033[43m","\033[48;5;208m","\033[41m","\033[45m","\033[44m","\033[47m"]
FLATPAK_CLI_COLORS = ["\033[42m","\033[43m","\033[48;5;208m","\033[41m","\033[45m","\033[44m"]

PACKAGE_TIERS = [100, 300, 600, 1000, 1500, 1800, 2000]
FLATPAK_TIERS = [5, 10, 20, 30, 40, 50]

# === Helpers ===
def get_label(count, max_value):
    percent = count / max_value
    if percent < 0.1: return "Minimal"
    elif percent < 0.3: return "Light"
    elif percent < 0.6: return "Moderate"
    elif percent < 0.8: return "Heavy"
    else: return "Extreme"

def get_position(count, max_value):
    return min(count / max_value, 1.0)

# === CLI bars ===
def draw_cli_bar(count, max_value, tiers, colors, label_prefix):
    BAR_LENGTH = BAR_LENGTH_CLI
    bar = ""
    last_threshold = 0
    for t_index, t_max in enumerate(tiers):
        tier_fraction = (t_max - last_threshold) / max_value
        blocks = max(1, int(tier_fraction * BAR_LENGTH))
        bar += colors[t_index] + "█" * blocks + RESET
        last_threshold = t_max
    bar_length_no_ansi = sum([1 for c in bar if c == "█"])
    if bar_length_no_ansi < BAR_LENGTH:
        bar += colors[-1] + "█" * (BAR_LENGTH - bar_length_no_ansi) + RESET
    pos = get_position(count, max_value)
    arrow_index = int(pos * BAR_LENGTH)
    print(f"{label_prefix}: {bar}")
    print(" " * arrow_index + "^ Current")
    print(f"{label_prefix} Total: {count} → {get_label(count, max_value)}\n")

# === GUI bars ===
def draw_gui_bars(canvas, packages, flatpaks):
    canvas.delete("all")
    # Packages
    block_width = BAR_LENGTH_GUI / len(PACKAGE_GUI_COLORS)
    for i, color in enumerate(PACKAGE_GUI_COLORS):
        canvas.create_rectangle(i*block_width, 0, (i+1)*block_width, BAR_HEIGHT, fill=color, outline="black")
    arrow_x = get_position(packages, MAX_PACKAGES) * BAR_LENGTH_GUI
    canvas.create_polygon(arrow_x, BAR_HEIGHT, arrow_x-10, BAR_HEIGHT+20, arrow_x+10, BAR_HEIGHT+20, fill="black")
    canvas.create_text(BAR_LENGTH_GUI/2, BAR_HEIGHT+30, text=f"Packages: {packages} → {get_label(packages, MAX_PACKAGES)}", font=("Arial",12))

    # Flatpaks
    y_offset = BAR_HEIGHT+60
    block_width = BAR_LENGTH_GUI / len(FLATPAK_GUI_COLORS)
    for i, color in enumerate(FLATPAK_GUI_COLORS):
        canvas.create_rectangle(i*block_width, y_offset, (i+1)*block_width, y_offset+BAR_HEIGHT, fill=color, outline="black")
    arrow_x = get_position(flatpaks, MAX_FLATPAKS) * BAR_LENGTH_GUI
    canvas.create_polygon(arrow_x, y_offset+BAR_HEIGHT, arrow_x-10, y_offset+BAR_HEIGHT+20, arrow_x+10, y_offset+BAR_HEIGHT+20, fill="black")
    canvas.create_text(BAR_LENGTH_GUI/2, y_offset+BAR_HEIGHT+30, text=f"Flatpaks: {flatpaks} → {get_label(flatpaks, MAX_FLATPAKS)}", font=("Arial",12))

# === GUI input window ===
def launch_gui_input():
    root = tk.Tk()
    root.title("Arch Bloat Meter Input")

    tk.Label(root, text="Enter total packages installed:").pack(pady=(10,0))
    packages_entry = tk.Entry(root)
    packages_entry.pack(pady=(0,10))

    tk.Label(root, text="Enter total flatpaks installed:").pack(pady=(10,0))
    flatpaks_entry = tk.Entry(root)
    flatpaks_entry.pack(pady=(0,10))

    canvas = tk.Canvas(root, width=BAR_LENGTH_GUI, height=BAR_HEIGHT*2+100)
    canvas.pack(pady=20)

    def submit():
        try:
            packages = int(packages_entry.get())
            flatpaks = int(flatpaks_entry.get())
        except ValueError:
            messagebox.showerror("Invalid input","Please enter valid integers!")
            return
        draw_gui_bars(canvas, packages, flatpaks)

    tk.Button(root, text="Show Bloat Bars", command=submit).pack(pady=(0,20))
    root.mainloop()

# === Main ===
if __name__ == "__main__":
    print("Select mode:")
    print("1) CLI")
    print("2) GUI")
    choice = input("Enter 1 or 2: ").strip()
    if choice == "1":
        try:
            packages = int(input("Enter total packages installed: "))
            flatpaks = int(input("Enter total flatpaks installed: "))
        except ValueError:
            print("Invalid input!")
            sys.exit(1)
        draw_cli_bar(packages, MAX_PACKAGES, PACKAGE_TIERS, PACKAGE_CLI_COLORS, "Packages")
        draw_cli_bar(flatpaks, MAX_FLATPAKS, FLATPAK_TIERS, FLATPAK_CLI_COLORS, "Flatpaks")
    else:
        launch_gui_input()
