#!/usr/bin/env python3
import tkinter as tk
from tkinter import messagebox, simpledialog, filedialog, font
import subprocess, time, json, os, random

# -------------------
# SETTINGS
# -------------------
SETTINGS_FILE = os.path.expanduser("~/.hyprmacros_settings.json")
DEFAULT_SETTINGS = {
    "theme": "dark",
    "typing_speed": 0.05,
    "default_browser": "zen-browser-bin",
    "default_media_player": "mpv"
}

# Load settings
try:
    with open(SETTINGS_FILE,"r") as f:
        SETTINGS = json.load(f)
except:
    SETTINGS = DEFAULT_SETTINGS.copy()

# -------------------
# THEMES
# -------------------
theme_dark = {"bg":"#1e1e2e","fg":"#c0caf5","accent":"#7aa2f7","button_bg":"#2e2e3e","button_fg":"#c0caf5"}
theme_light = {"bg":"#f0f0f0","fg":"#000000","accent":"#0077cc","button_bg":"#e0e0e0","button_fg":"#000000"}
theme_pastel = {"bg":"#fdf6f0","fg":"#333333","accent":"#ffb6c1","button_bg":"#ffe4e1","button_fg":"#333333"}
theme_colors = {"dark":theme_dark,"light":theme_light,"pastel":theme_pastel}[SETTINGS["theme"]]

# -------------------
# CORE FUNCTIONS
# -------------------
def run_keypress(keys, app=None):
    if app:
        subprocess.Popen(f"bash -lc 'xdotool search --class {app} windowactivate key \"{keys}\"'",shell=True)
    else:
        subprocess.run(["wtype", keys])

def run_type_text(text, app=None):
    for ch in text:
        run_keypress(ch, app)
        time.sleep(SETTINGS["typing_speed"])

def run_clipboard_write(text):
    subprocess.run(["wl-copy"], input=text.encode())

def run_clipboard_append(text):
    current = subprocess.run(["wl-paste"], capture_output=True, text=True).stdout
    run_clipboard_write(current+text)

def run_clipboard_read():
    return subprocess.run(["wl-paste"], capture_output=True, text=True).stdout.strip()

def run_notify(msg):
    subprocess.run(["notify-send", msg])

def run_launch_app(command):
    # login shell to support aliases
    subprocess.Popen(f"bash -lc '{command}'", shell=True, cwd=os.path.expanduser("~"))

def run_kill_app(proc):
    subprocess.run(["killall", proc])

def run_wait(seconds):
    time.sleep(float(seconds))

def run_wait_random(min_s,max_s):
    time.sleep(random.uniform(float(min_s),float(max_s)))

def run_open_url(url, app=None):
    if not url.startswith(("http://","https://")):
        url = "https://"+url
    if app:
        subprocess.Popen([app,url])
    else:
        subprocess.Popen([SETTINGS["default_browser"],url])

def run_open_file(path):
    subprocess.Popen(["xdg-open",path])

def run_volume_change(delta):
    subprocess.run(["pactl","set-sink-volume","@DEFAULT_SINK@",delta])

def run_mute_toggle():
    subprocess.run(["pactl","set-sink-mute","@DEFAULT_SINK@","toggle"])

# -------------------
# MACRO MANAGEMENT
# -------------------
macro_blocks = []
collapsed_list = []

descriptions = {
    "Key Press":"Press keys or combos (optional app focus).",
    "Type Text":"Type text like a human (optional app).",
    "Clipboard Write":"Set clipboard content.",
    "Clipboard Read":"Print clipboard content to console.",
    "Clipboard Append":"Append text to clipboard.",
    "Notify":"Show notification.",
    "Launch App":"Run an app (bash aliases supported). For Flatpak, type 'flatpak run <full-name>'.",
    "Kill App":"Kill a process by name.",
    "Wait":"Wait fixed seconds.",
    "Wait Random":"Wait random seconds between min and max.",
    "Open URL":"Open URL (optionally in specified app).",
    "Open File":"Open a file with default app.",
    "Volume Up":"Increase volume by 5%.",
    "Volume Down":"Decrease volume by 5%.",
    "Mute Toggle":"Toggle mute.",
    "Loop":"Repeat sub-blocks N times.",
    "If Clipboard Contains":"Execute sub-blocks if clipboard matches text.",
    "Input Box":"Ask user for input and store in variable.",
}

# -------------------
# GUI HELPERS
# -------------------
block_type_var = None
right_frame = None

def refresh_blocks():
    for child in right_frame.winfo_children():
        child.destroy()
    for idx, block in enumerate(macro_blocks):
        frame = tk.Frame(right_frame,bg=theme_colors["bg"],bd=1,relief=tk.SOLID,padx=3,pady=3)
        frame.pack(fill=tk.X,pady=2)
        collapsed = tk.BooleanVar(value=True)
        header = tk.Frame(frame,bg=theme_colors["bg"])
        header.pack(fill=tk.X)
        tk.Label(header,text=f"{block['type']}: {block['value'][:30]}{'...' if len(block['value'])>30 else ''}",bg=theme_colors["bg"],fg=theme_colors["fg"]).pack(side=tk.LEFT)
        def toggle(idx=idx):
            collapsed_list[idx] = not collapsed_list[idx]
            refresh_blocks()
        tk.Button(header,text="Expand" if collapsed.get() else "Collapse",command=toggle,bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1).pack(side=tk.RIGHT)
        if not collapsed.get():
            tk.Label(frame,text=f"Full Value: {block['value']}",wraplength=400,bg=theme_colors["bg"],fg="blue").pack(fill=tk.X,pady=2)
            tk.Button(frame,text="Remove",command=lambda i=idx: remove_block_by_index(i),bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1).pack(pady=2)

def remove_block_by_index(idx):
    macro_blocks.pop(idx)
    collapsed_list.pop(idx)
    refresh_blocks()

def add_block():
    block_type = block_type_var.get()
    if not block_type:
        messagebox.showerror("Error","Select block type")
        return
    if block_type=="Launch App":
        val = simpledialog.askstring(f"{block_type} Value",
            descriptions.get(block_type,"Enter value")+
            "\n(Note: For Flatpak apps, type 'flatpak run <full-flatpak-name>')")
    else:
        val = simpledialog.askstring(f"{block_type} Value",descriptions.get(block_type,"Enter value"))
    if val is None: return
    app = None
    if block_type in ["Key Press","Type Text","Wait for Window"]:
        app = simpledialog.askstring("App Name","Optional app/window class")
    sub_blocks = []
    if block_type in ["Loop","If Clipboard Contains"]:
        sub_blocks=[]
    macro_blocks.append({"type":block_type,"value":val,"app":app,"sub_blocks":sub_blocks})
    collapsed_list.append(True)
    refresh_blocks()

def remove_block():
    if macro_blocks:
        remove_block_by_index(len(macro_blocks)-1)

def play_macro():
    for block in macro_blocks:
        execute_block(block)

def execute_block(block):
    t = block['type']
    v = block['value']
    a = block['app']
    if t=="Key Press": run_keypress(v,a)
    elif t=="Type Text": run_type_text(v,a)
    elif t=="Clipboard Write": run_clipboard_write(v)
    elif t=="Clipboard Append": run_clipboard_append(v)
    elif t=="Clipboard Read": print(run_clipboard_read())
    elif t=="Notify": run_notify(v)
    elif t=="Launch App": run_launch_app(v)
    elif t=="Kill App": run_kill_app(v)
    elif t=="Wait": run_wait(v)
    elif t=="Wait Random":
        parts=v.split(",")
        run_wait_random(parts[0],parts[1])
    elif t=="Open URL": run_open_url(v,a)
    elif t=="Open File": run_open_file(v)
    elif t=="Volume Up": run_volume_change("+5%")
    elif t=="Volume Down": run_volume_change("-5%")
    elif t=="Mute Toggle": run_mute_toggle()
    elif t=="Loop":
        times=int(v)
        for _ in range(times):
            for sb in block['sub_blocks']:
                execute_block(sb)
    elif t=="If Clipboard Contains":
        if run_clipboard_read()==v:
            for sb in block['sub_blocks']:
                execute_block(sb)

def export_macro():
    path = filedialog.asksaveasfilename(defaultextension=".py",filetypes=[("Python Files","*.py")])
    if not path: return
    with open(path,"w") as f:
        f.write("import subprocess, time, random, os\n\n")
        f.write("def run_macro():\n")
        def write_block(block,indent=1):
            prefix="    "*indent
            t = block['type']
            v = block['value']
            a = block['app']
            sb = block['sub_blocks']
            if t=="Key Press": f.write(f"{prefix}subprocess.run(['wtype','{v}'])\n")
            elif t=="Type Text":
                for ch in v: f.write(f"{prefix}subprocess.run(['wtype','{ch}']); time.sleep({SETTINGS['typing_speed']})\n")
            elif t=="Clipboard Write": f.write(f"{prefix}subprocess.run(['wl-copy'],input='{v}'.encode())\n")
            elif t=="Clipboard Append": f.write(f"{prefix}curr=subprocess.run(['wl-paste'],capture_output=True,text=True).stdout; subprocess.run(['wl-copy'],input=(curr+'{v}').encode())\n")
            elif t=="Clipboard Read": f.write(f"{prefix}import subprocess; print(subprocess.run(['wl-paste'],capture_output=True,text=True).stdout)\n")
            elif t=="Notify": f.write(f"{prefix}subprocess.run(['notify-send','{v}'])\n")
            elif t=="Launch App": f.write(f"{prefix}subprocess.Popen(f\"bash -lc '{v}'\",shell=True,cwd=os.path.expanduser('~'))\n")
            elif t=="Kill App": f.write(f"{prefix}subprocess.run(['killall','{v}'])\n")
            elif t=="Wait": f.write(f"{prefix}time.sleep({v})\n")
            elif t=="Wait Random":
                p=v.split(",")
                f.write(f"{prefix}time.sleep(random.uniform({p[0]},{p[1]}))\n")
            elif t=="Open URL":
                url=v if v.startswith(('http://','https://')) else f'https://{v}'
                if a:
                    f.write(f"{prefix}subprocess.Popen(['{a}','{url}'])\n")
                else:
                    f.write(f"{prefix}subprocess.Popen(['{SETTINGS['default_browser']}','{url}'])\n")
            elif t=="Open File": f.write(f"{prefix}subprocess.Popen(['xdg-open','{v}'])\n")
            elif t=="Volume Up": f.write(f"{prefix}subprocess.run(['pactl','set-sink-volume','@DEFAULT_SINK@','+5%'])\n")
            elif t=="Volume Down": f.write(f"{prefix}subprocess.run(['pactl','set-sink-volume','@DEFAULT_SINK@','-5%'])\n")
            elif t=="Mute Toggle": f.write(f"{prefix}subprocess.run(['pactl','set-sink-mute','@DEFAULT_SINK@','toggle'])\n")
            elif t=="Loop":
                f.write(f"{prefix}for _ in range({v}):\n")
                for sb in sb: write_block(sb,indent+1)
            elif t=="If Clipboard Contains":
                f.write(f"{prefix}import subprocess\n")
                f.write(f"{prefix}if subprocess.run(['wl-paste'],capture_output=True,text=True).stdout.strip()=='{v}':\n")
                for sb in sb: write_block(sb,indent+1)
        for block in macro_blocks: write_block(block)
        f.write("\nif __name__=='__main__':\n    run_macro()\n")
    messagebox.showinfo("Saved",f"Macro exported to:\n{path}")

# -------------------
# SETTINGS GUI
# -------------------
def open_settings():
    top=tk.Toplevel(root)
    top.title("Settings")
    tk.Label(top,text="Theme:").pack()
    theme_var=tk.StringVar(value=SETTINGS["theme"])
    tk.OptionMenu(top,theme_var,*theme_colors.keys()).pack()
    tk.Label(top,text="Typing Speed:").pack()
    speed_var=tk.DoubleVar(value=SETTINGS["typing_speed"])
    tk.Scale(top,variable=speed_var,from_=0.01,to=0.3,resolution=0.01,orient=tk.HORIZONTAL).pack()
    def save_settings():
        SETTINGS["theme"]=theme_var.get()
        SETTINGS["typing_speed"]=speed_var.get()
        try:
            with open(SETTINGS_FILE,"w") as f: json.dump(SETTINGS,f)
        except Exception as e:
            messagebox.showerror("Error",f"Failed to save settings: {e}")
        messagebox.showinfo("Saved","Settings updated")
        top.destroy()
    tk.Button(top,text="Save",command=save_settings).pack(pady=5)

# -------------------
# TKINTER GUI
# -------------------
root=tk.Tk()
root.title("HyprMacros")
root.geometry("950x600")
default_font = font.nametofont("TkDefaultFont")
default_font.configure(family="Monocraft", size=11)
root.option_add("*Font","Monocraft 11")
root.configure(bg=theme_colors["bg"])

# Top buttons
top_frame=tk.Frame(root,bg=theme_colors["bg"],bd=1,relief=tk.SOLID,padx=5,pady=5)
top_frame.pack(side=tk.TOP,fill=tk.X,pady=5)
tk.Button(top_frame,text="Play Macro",command=play_macro,bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1,relief=tk.RAISED).pack(side=tk.LEFT,padx=5)
tk.Button(top_frame,text="Export Macro",command=export_macro,bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1,relief=tk.RAISED).pack(side=tk.LEFT,padx=5)
tk.Button(top_frame,text="Remove Selected",command=remove_block,bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1,relief=tk.RAISED).pack(side=tk.LEFT,padx=5)
tk.Button(top_frame,text="Settings",command=open_settings,bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1,relief=tk.RAISED).pack(side=tk.RIGHT,padx=5)

# Left panel
left_frame=tk.Frame(root,bg=theme_colors["bg"],bd=1,relief=tk.SOLID,padx=5,pady=5)
left_frame.pack(side=tk.LEFT,fill=tk.Y,padx=5,pady=5)
tk.Label(left_frame,text="Block Type:",bg=theme_colors["bg"],fg=theme_colors["fg"]).pack(pady=2)
block_type_var=tk.StringVar()
tk.OptionMenu(left_frame,block_type_var,*list(descriptions.keys())).pack(pady=2)
description_label=tk.Label(left_frame,text="",wraplength=180,fg=theme_colors["accent"],bg=theme_colors["bg"])
description_label.pack(pady=5)
tk.Button(left_frame,text="Add Block",command=add_block,bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1,relief=tk.RAISED).pack(pady=2)
tk.Button(left_frame,text="Remove Block",command=remove_block,bg=theme_colors["button_bg"],fg=theme_colors["button_fg"],bd=1,relief=tk.RAISED).pack(pady=2)

# Right panel
right_frame=tk.Frame(root,bg=theme_colors["bg"],bd=1,relief=tk.SOLID,padx=5,pady=5)
right_frame.pack(side=tk.LEFT,fill=tk.BOTH,expand=True,padx=5,pady=5)
tk.Label(right_frame,text="Macro Blocks:",bg=theme_colors["bg"],fg=theme_colors["fg"]).pack()

# -------------------
# RUN GUI
# -------------------
root.mainloop()
