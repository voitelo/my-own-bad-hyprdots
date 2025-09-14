import tkinter as tk
from tkinter import ttk, simpledialog, messagebox
import subprocess

# -------- Utility --------
def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
    except:
        return ""

def detect_sound_server():
    try:
        info = subprocess.check_output(["pactl", "info"]).decode()
        if "PulseAudio" in info:
            return "PulseAudio"
        elif "PipeWire" in info:
            return "PipeWire"
    except:
        return "Unknown"

def wifi_state():
    return run_cmd(["nmcli", "radio", "wifi"])

def bluetooth_state():
    output = run_cmd(["rfkill", "list", "bluetooth"])
    return "blocked: yes" not in output

# -------- Main App --------
class SuperNM(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Super Network Manager")
        self.geometry("650x500")
        self.configure(bg="#1c1c1c", bd=4, highlightbackground="#d06fc6", highlightthickness=4)

        self.sound_server = detect_sound_server()
        self.current_frame = None
        self.bt_devices_cache = {}

        self.create_sidebar()
        self.show_frame("Wi-Fi")

    # -------- Sidebar --------
    def create_sidebar(self):
        self.sidebar = tk.Frame(self, bg="#2c2c2c", width=160)
        self.sidebar.pack(side="left", fill="y")

        sections = ["Wi-Fi", "Bluetooth", "Airplane Mode", f"Sound ({self.sound_server})", "Brightness"]
        self.menu_buttons = {}
        for sec in sections:
            btn = tk.Button(self.sidebar, text=sec, bg="#4a6fa5", fg="white", bd=0, font=("Segoe UI", 12),
                            command=lambda s=sec: self.show_frame(s))
            btn.pack(fill="x", padx=5, pady=5)
            self.menu_buttons[sec] = btn

    # -------- Frame Switching --------
    def show_frame(self, section):
        if self.current_frame:
            self.current_frame.destroy()
        self.current_frame = tk.Frame(self, bg="#1c1c1c")
        self.current_frame.pack(side="left", fill="both", expand=True)

        if section == "Wi-Fi":
            self.populate_wifi()
        elif section == "Bluetooth":
            self.populate_bluetooth()
        elif section == "Airplane Mode":
            self.populate_airplane()
        elif "Sound" in section:
            self.populate_sound()
        elif section == "Brightness":
            self.populate_brightness()

    # -------- Wi-Fi --------
    def populate_wifi(self):
        tk.Label(self.current_frame, text="Wi-Fi Networks", font=("Segoe UI", 16), bg="#1c1c1c", fg="#4a6fa5").pack(pady=10)
        self.wifi_toggle_btn = tk.Button(self.current_frame, text=f"Toggle Wi-Fi ({wifi_state()})", bg="#4a6fa5", fg="white", command=self.toggle_wifi)
        self.wifi_toggle_btn.pack(pady=5)

        self.wifi_status_label = tk.Label(self.current_frame, text="", bg="#1c1c1c", fg="#4a6fa5", font=("Segoe UI", 12))
        self.wifi_status_label.pack(pady=5)

        canvas_frame = tk.Frame(self.current_frame, bg="#1c1c1c")
        canvas_frame.pack(fill="both", expand=True, padx=20, pady=10)

        self.wifi_canvas = tk.Canvas(canvas_frame, bg="#1c1c1c", highlightthickness=0)
        self.wifi_canvas.pack(side="left", fill="both", expand=True)

        scrollbar = tk.Scrollbar(canvas_frame, orient="vertical", command=self.wifi_canvas.yview)
        scrollbar.pack(side="right", fill="y")
        self.wifi_canvas.configure(yscrollcommand=scrollbar.set)

        self.wifi_inner = tk.Frame(self.wifi_canvas, bg="#1c1c1c")
        self.wifi_canvas.create_window((0, 0), window=self.wifi_inner, anchor="nw")
        self.wifi_inner.bind("<Configure>", lambda e: self.wifi_canvas.configure(scrollregion=self.wifi_canvas.bbox("all")))

        self.update_networks()
        self.update_wifi_status()

    def toggle_wifi(self):
        state = wifi_state()
        if state.lower() == "enabled":
            subprocess.run(["nmcli", "radio", "wifi", "off"])
        else:
            subprocess.run(["nmcli", "radio", "wifi", "on"])
        self.update_networks()

    def update_networks(self):
        if not self.wifi_inner.winfo_exists():
            return
        for widget in self.wifi_inner.winfo_children():
            widget.destroy()
        self.wifi_toggle_btn.config(text=f"Toggle Wi-Fi ({wifi_state()})")
        try:
            result = subprocess.check_output(["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL,ACTIVE", "device", "wifi", "list"]).decode()
            networks = [line.split(":") for line in result.strip().split("\n") if line]
            for net in networks:
                ssid, sec, signal, active = net
                status = " (connected)" if active == "yes" else ""
                frame = tk.Frame(self.wifi_inner, bg="#1c1c1c")
                frame.pack(fill="x", pady=2)
                tk.Label(frame, text=f"{ssid}", bg="#1c1c1c", fg="white", font=("Segoe UI", 12)).pack(side="left", padx=5)
                tk.Label(frame, text=f"{sec} | {signal}%{status}", bg="#1c1c1c", fg="#aaa", font=("Segoe UI", 10)).pack(side="right", padx=5)
                frame.bind("<Button-1>", lambda e, s=ssid: self.connect_to_ssid(s))
                for child in frame.winfo_children():
                    child.bind("<Button-1>", lambda e, s=ssid: self.connect_to_ssid(s))
                tk.Frame(self.wifi_inner, bg="#4a6fa5", height=1).pack(fill="x")
        except:
            tk.Label(self.wifi_inner, text="Failed to list networks", bg="#1c1c1c", fg="red").pack()
        self.after(5000, self.update_networks)

    def connect_to_ssid(self, ssid):
        existing = run_cmd(["nmcli", "-t", "-f", "NAME", "connection", "show"]).splitlines()
        if ssid in existing:
            ret = subprocess.run(["nmcli", "connection", "up", ssid], capture_output=True)
        else:
            pwd = simpledialog.askstring("Wi-Fi Password", f"Enter password for {ssid}:", show="*")
            if not pwd:
                return
            ret = subprocess.run(["nmcli", "device", "wifi", "connect", ssid, "password", pwd], capture_output=True)
        if self.wifi_status_label.winfo_exists():
            if ret.returncode == 0:
                self.wifi_status_label.config(text=f"Connected to {ssid}")
            else:
                self.wifi_status_label.config(text=f"Failed to connect to {ssid}")

    def update_wifi_status(self):
        if not self.wifi_status_label.winfo_exists():
            return
        status_text = "Wi-Fi disabled"
        if wifi_state().lower() == "enabled":
            try:
                result = subprocess.check_output(["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]).decode().splitlines()
                connected = next((line.split(":")[1] for line in result if line.startswith("yes:")), None)
                status_text = f"Connected to {connected}" if connected else "Not connected"
            except:
                status_text = "Status unknown"
        self.wifi_status_label.config(text=status_text)
        self.after(2000, self.update_wifi_status)

    # -------- Bluetooth --------
    def populate_bluetooth(self):
        tk.Label(self.current_frame, text="Bluetooth Devices", font=("Segoe UI", 16), bg="#1c1c1c", fg="#4a6fa5").pack(pady=10)
        tk.Button(self.current_frame, text="Toggle Bluetooth", bg="#4a6fa5", fg="white", command=self.toggle_bluetooth).pack(pady=5)

        canvas_frame = tk.Frame(self.current_frame, bg="#1c1c1c")
        canvas_frame.pack(fill="both", expand=True, padx=20, pady=10)

        self.bt_canvas = tk.Canvas(canvas_frame, bg="#1c1c1c", highlightthickness=0)
        self.bt_canvas.pack(side="left", fill="both", expand=True)

        scrollbar = tk.Scrollbar(canvas_frame, orient="vertical", command=self.bt_canvas.yview)
        scrollbar.pack(side="right", fill="y")
        self.bt_canvas.configure(yscrollcommand=scrollbar.set)

        self.bt_inner = tk.Frame(self.bt_canvas, bg="#1c1c1c")
        self.bt_canvas.create_window((0, 0), window=self.bt_inner, anchor="nw")
        self.bt_inner.bind("<Configure>", lambda e: self.bt_canvas.configure(scrollregion=self.bt_canvas.bbox("all")))

        self.update_bluetooth_loop()

    def toggle_bluetooth(self):
        subprocess.run(["rfkill", "toggle", "bluetooth"])
        self.update_bluetooth_loop()

    def update_bluetooth_loop(self):
        if not self.bt_inner.winfo_exists():
            return
        output = run_cmd(["bluetoothctl", "devices"]).splitlines()
        current_devices = {}
        for line in output:
            parts = line.split(" ", 2)
            if len(parts) >= 3:
                mac = parts[1]
                name = parts[2]
                current_devices[mac] = name
                if mac not in self.bt_devices_cache:
                    frame = tk.Frame(self.bt_inner, bg="#1c1c1c")
                    frame.pack(fill="x", pady=2)
                    tk.Label(frame, text=name, bg="#1c1c1c", fg="white", font=("Segoe UI", 12)).pack(side="left", padx=5)
                    tk.Label(frame, text=mac, bg="#1c1c1c", fg="#aaa", font=("Segoe UI", 10)).pack(side="right", padx=5)
                    frame.bind("<Button-1>", lambda e, m=mac: self.connect_bluetooth_device(m))
                    for child in frame.winfo_children():
                        child.bind("<Button-1>", lambda e, m=mac: self.connect_bluetooth_device(m))
                    tk.Frame(self.bt_inner, bg="#4a6fa5", height=1).pack(fill="x")
                    self.bt_devices_cache[mac] = frame

        for mac in list(self.bt_devices_cache.keys()):
            if mac not in current_devices:
                self.bt_devices_cache[mac].destroy()
                del self.bt_devices_cache[mac]

        self.after(5000, self.update_bluetooth_loop)

    def connect_bluetooth_device(self, mac):
        ret = run_cmd(["bluetoothctl", "connect", mac])
        messagebox.showinfo("Bluetooth", f"Connect command sent to {mac}\n{ret}")

    # -------- Airplane Mode --------
    def populate_airplane(self):
        tk.Label(self.current_frame, text="Airplane Mode", font=("Segoe UI", 16), bg="#1c1c1c", fg="#4a6fa5").pack(pady=10)
        tk.Button(self.current_frame, text="Toggle Airplane Mode", bg="#4a6fa5", fg="white", command=self.toggle_airplane).pack(pady=20)

    def toggle_airplane(self):
        wifi_on = wifi_state().lower() == "enabled"
        bt_on = bluetooth_state()
        if wifi_on or bt_on:
            subprocess.run(["nmcli", "radio", "wifi", "off"])
            subprocess.run(["rfkill", "block", "bluetooth"])
            messagebox.showinfo("Airplane Mode", "Wi-Fi and Bluetooth turned OFF")
        else:
            subprocess.run(["nmcli", "radio", "wifi", "on"])
            subprocess.run(["rfkill", "unblock", "bluetooth"])
            messagebox.showinfo("Airplane Mode", "Wi-Fi and Bluetooth turned ON")

    # -------- Sound --------
    def populate_sound(self):
        tk.Label(self.current_frame, text=f"Sound ({self.sound_server})", font=("Segoe UI", 16), bg="#1c1c1c", fg="#4a6fa5").pack(pady=10)
        try:
            info = run_cmd(["pactl", "get-sink-volume", "@DEFAULT_SINK@"])
            percent = int(info.split("/")[1].strip().replace("%",""))
        except:
            percent = 50

        self.vol_slider = ttk.Scale(self.current_frame, from_=0, to=100, orient="horizontal", command=self.set_volume)
        self.vol_slider.set(percent)
        self.vol_slider.pack(fill="x", padx=20, pady=5)
        self.vol_slider.bind("<Left>", lambda e: self.change_volume(-5))
        self.vol_slider.bind("<Right>", lambda e: self.change_volume(5))
        tk.Button(self.current_frame, text="Mute/Unmute", bg="#4a6fa5", fg="white", command=self.toggle_mute).pack(pady=5)

    def set_volume(self, val):
        subprocess.run(["pactl", "set-sink-volume", "@DEFAULT_SINK@", f"{int(float(val))}%"])

    def change_volume(self, delta):
        current = int(self.vol_slider.get())
        new = max(0, min(100, current + delta))
        self.vol_slider.set(new)
        self.set_volume(new)

    def toggle_mute(self):
        subprocess.run(["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"])

    # -------- Brightness --------
    def populate_brightness(self):
        tk.Label(self.current_frame, text="Brightness", font=("Segoe UI", 16), bg="#1c1c1c", fg="#4a6fa5").pack(pady=10)
        try:
            current = int(run_cmd(["brightnessctl", "get"]))
            max_val = int(run_cmd(["brightnessctl", "max"]))
            percent = current * 100 / max_val
        except:
            percent = 75
        self.bright_slider = ttk.Scale(self.current_frame, from_=0, to=100, orient="horizontal", command=self.set_brightness)
        self.bright_slider.set(percent)
        self.bright_slider.pack(fill="x", padx=20, pady=5)
        self.bright_slider.bind("<Left>", lambda e: self.change_brightness(-5))
        self.bright_slider.bind("<Right>", lambda e: self.change_brightness(5))

    def set_brightness(self, val):
        subprocess.run(["brightnessctl", "set", f"{int(float(val))}%"])

    def change_brightness(self, delta):
        current = int(self.bright_slider.get())
        new = max(0, min(100, current + delta))
        self.bright_slider.set(new)
        self.set_brightness(new)

# -------- Run --------
if __name__ == "__main__":
    app = SuperNM()
    app.mainloop()
