#!/usr/bin/python3

import os
import threading
import tkinter as tk
from tkinter import ttk
import platform
from tkinter import messagebox

class SimpleFileManager(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Simple File Manager with Smart Search")
        self.geometry("900x600")

        # Slight overall transparency (works if your OS compositor supports it)
        try:
            self.attributes("-alpha", 0.94)  # tweak between 0.0 (invisible) and 1.0 (opaque)
        except Exception:
            pass  # some platforms may not allow changing alpha

        # Base blue used for panels and imitation of transparency
        self.base_blue = "#3A5FCD"
        self.alt_blue = "#3354b0"   # slightly darker stripe
        self.light_blue = "#4A75E0" # slightly lighter stripe
        self.configure(bg=self.base_blue)

        self.current_path = os.path.expanduser("~")
        self.history = [self.current_path]
        self.history_index = 0
        self.show_dotfiles = True

        self.search_thread = None
        self.stop_search = False

        self.create_widgets()
        self.load_files()


    def on_file_double_click(file_path):
        if messagebox.askyesno("Open in Micro", f"Do you want to open '{file_path}' in Kitty with Micro?"):
            subprocess.Popen(["kitty", "micro", file_path])

    def create_widgets(self):
        # Main container
        container = tk.Frame(self, bg=self.base_blue)
        container.pack(fill=tk.BOTH, expand=True)

        # Sidebar
        sidebar = tk.Frame(container, width=220, bg=self.alt_blue)
        sidebar.pack(side=tk.LEFT, fill=tk.Y)
        sidebar.pack_propagate(False)

        tk.Label(sidebar, text="Quick shortcuts", bg=self.alt_blue, fg="white", font=("Segoe UI", 11, "bold")).pack(pady=(12,6))

        shortcuts = [
            ("Home", os.path.expanduser("~")),
            ("Downloads", os.path.join(os.path.expanduser("~"), "Downloads")),
            ("Documents", os.path.join(os.path.expanduser("~"), "Documents")),
            ("Desktop", os.path.join(os.path.expanduser("~"), "Desktop")),
        ]
        for name, path in shortcuts:
            b = tk.Button(sidebar, text=name, anchor="w", relief=tk.FLAT,
                          bg=self.light_blue, fg="white", command=lambda p=path: self.change_directory(p))
            b.pack(fill=tk.X, padx=12, pady=3)

        tk.Label(sidebar, text="Drives", bg=self.alt_blue, fg="white", font=("Segoe UI", 11, "bold")).pack(pady=(14,6))
        self.drives_frame = tk.Frame(sidebar, bg=self.alt_blue)
        self.drives_frame.pack(fill=tk.X, padx=8)
        self.list_drives()

        # Right panel (toolbar + file list)
        right_panel = tk.Frame(container, bg=self.base_blue)
        right_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        # Toolbar
        toolbar = tk.Frame(right_panel, bg=self.base_blue)
        toolbar.pack(fill=tk.X, pady=8, padx=8)

        self.search_var = tk.StringVar()
        entry = tk.Entry(toolbar, textvariable=self.search_var, font=("Segoe UI", 11))
        entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0,6))
        entry.bind("<Return>", lambda e: self.start_search())

        tk.Button(toolbar, text="Search", command=self.start_search).pack(side=tk.LEFT, padx=(0,6))
        tk.Button(toolbar, text="Clear search", command=self.clear_search).pack(side=tk.LEFT)

        # Treeview (Type + Path). We'll fake transparency with alternating blue rows.
        columns = ("Type", "Path")
        self.tree = ttk.Treeview(right_panel, columns=columns, show="headings")
        self.tree.heading("Type", text="Type")
        self.tree.heading("Path", text="Path")
        self.tree.column("Type", width=80, anchor="center")
        self.tree.column("Path", anchor="w")
        self.tree.pack(fill=tk.BOTH, expand=True, padx=8, pady=(6,0))

        # Vertical scrollbar
        vs = ttk.Scrollbar(self.tree.master, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=vs.set)
        vs.place(relx=1.0, rely=0, relheight=1.0, anchor="ne")

        # Style the headings and overall tree background to match the blue
        style = ttk.Style(self)
        style.theme_use(style.theme_use())  # keep current theme
        style.configure("Treeview",
                        background=self.base_blue,
                        fieldbackground=self.base_blue,
                        foreground="white",
                        font=("Segoe UI", 10),
                        rowheight=24)
        style.configure("Treeview.Heading", font=("Segoe UI", 10, "bold"), background=self.alt_blue, foreground="white")

        # Row tag colors (alternating)
        self.tree.tag_configure("odd", background=self.light_blue, foreground="white")
        self.tree.tag_configure("even", background=self.base_blue, foreground="white")
        # Selected item style (works visually on many platforms)
        style.map("Treeview",
                  background=[("selected", "#5B7FFF")],
                  foreground=[("selected", "black")])

        self.status_label = tk.Label(right_panel, text="", bg=self.base_blue, fg="white", anchor="w")
        self.status_label.pack(fill=tk.X, padx=8, pady=6)

        # Bind double click to open folder
        self.tree.bind("<Double-1>", self.on_double_click)
        self.tree.bind("<Button-3>", self.on_right_click)

    def list_drives(self):
        for w in self.drives_frame.winfo_children():
            w.destroy()
        for d in self.get_drives():
            b = tk.Button(self.drives_frame, text=d, anchor="w", relief=tk.FLAT,
                          bg=self.light_blue, fg="white", command=lambda p=d: self.change_directory(p))
            b.pack(fill=tk.X, pady=2)

    def get_drives(self):
        system = platform.system()
        drives = []
        if system == "Windows":
            import string
            from ctypes import windll
            bitmask = windll.kernel32.GetLogicalDrives()
            for i, letter in enumerate(string.ascii_uppercase):
                if bitmask & (1 << i):
                    drives.append(f"{letter}:/")
        else:
            # show root and common mount points
            drives = ["/"]
            for base in ("/mnt", "/media", "/run/media"):
                if os.path.isdir(base):
                    try:
                        for name in os.listdir(base):
                            drives.append(os.path.join(base, name))
                    except PermissionError:
                        pass
        return drives

    def change_directory(self, path):
        if os.path.isdir(path):
            self.current_path = path
            self.history.append(path)
            self.history_index = len(self.history) - 1
            self.load_files()
            self.status_label.config(text=f"Current directory: {self.current_path}")

    def load_files(self):
        self.status_label.config(text="")
        self.tree.delete(*self.tree.get_children())
        try:
            entries = os.listdir(self.current_path)
        except PermissionError:
            entries = []

        entries = [e for e in entries if self.show_dotfiles or not e.startswith(".")]

        dirs = sorted([e for e in entries if os.path.isdir(os.path.join(self.current_path, e))])
        files = sorted([e for e in entries if os.path.isfile(os.path.join(self.current_path, e))])

        i = 0
        for d in dirs:
            full = os.path.join(self.current_path, d)
            tag = "even" if i % 2 == 0 else "odd"
            self.tree.insert("", "end", values=("Folder", full), tags=(tag,))
            i += 1
        for f in files:
            full = os.path.join(self.current_path, f)
            tag = "even" if i % 2 == 0 else "odd"
            self.tree.insert("", "end", values=("File", full), tags=(tag,))
            i += 1

    def start_search(self):
        query = self.search_var.get().strip()
        if not query:
            return
        if self.search_thread and self.search_thread.is_alive():
            self.stop_search = True
            self.search_thread.join()
        self.stop_search = False
        self.status_label.config(text="Searching...")
        self.tree.delete(*self.tree.get_children())
        self.search_thread = threading.Thread(target=self.perform_search, args=(query,), daemon=True)
        self.search_thread.start()

    def perform_search(self, query):
        results = []
        try:
            entries = os.listdir(self.current_path)
        except PermissionError:
            entries = []

        for entry in entries:
            if self.stop_search:
                return
            if query.lower() in entry.lower():
                results.append(os.path.join(self.current_path, entry))

        if results:
            self.show_results(results)
            return

        # search filesystem root (fast name search)
        root = "/"
        if platform.system() == "Windows":
            root = None  # will loop drive letters instead
        results = []
        if root is None:
            for d in self.get_drives():
                for rootdir, dirs, files in os.walk(d):
                    if self.stop_search:
                        return
                    for name in dirs + files:
                        if self.stop_search:
                            return
                        if query.lower() in name.lower():
                            results.append(os.path.join(rootdir, name))
                        if len(results) >= 200:
                            break
                    if len(results) >= 200:
                        break
        else:
            for rootdir, dirs, files in os.walk(root):
                if self.stop_search:
                    return
                for name in dirs + files:
                    if self.stop_search:
                        return
                    if query.lower() in name.lower():
                        results.append(os.path.join(rootdir, name))
                    if len(results) >= 200:
                        break
                if len(results) >= 200:
                    break

        if results:
            self.show_results(results)
            return

        # grep-like content search in small text files
        results = []
        roots = self.get_drives() if root is None else [root]
        for r in roots:
            for rootdir, dirs, files in os.walk(r):
                if self.stop_search:
                    return
                for f in files:
                    if self.stop_search:
                        return
                    path = os.path.join(rootdir, f)
                    try:
                        if os.path.getsize(path) > 1024 * 1024:
                            continue
                        with open(path, "r", errors="ignore") as fh:
                            for line in fh:
                                if query.lower() in line.lower():
                                    results.append(path)
                                    break
                        if len(results) >= 100:
                            break
                    except Exception:
                        continue
                if len(results) >= 100:
                    break
            if len(results) >= 100:
                break

        if results:
            self.show_results(results)
        else:
            self.after(0, lambda: self.status_label.config(text="Sorry, we couldn’t find the file/file contents you were looking for."))

    def show_results(self, results):
        def ui():
            self.tree.delete(*self.tree.get_children())
            for i, path in enumerate(results):
                tag = "even" if i % 2 == 0 else "odd"
                typ = "Folder" if os.path.isdir(path) else "File"
                self.tree.insert("", "end", values=(typ, path), tags=(tag,))
            self.status_label.config(text=f"Found {len(results)} results.")
        self.after(0, ui)

    def clear_search(self):
        if self.search_thread and self.search_thread.is_alive():
            self.stop_search = True
            self.search_thread.join()
        self.search_var.set("")
        self.status_label.config(text="")
        self.load_files()

    def on_double_click(self, event):
        item = self.tree.focus()
        if not item:
            return
        vals = self.tree.item(item, "values")
        if not vals:
            return
        path = vals[1]  # Path column
        if os.path.isdir(path):
            self.change_directory(path)

    def on_right_click(self, event):
        menu = tk.Menu(self, tearoff=0)
    
        # Get current directory path (shorten if too long)
        path = self.current_path
        display_path = path
        if len(path) > 40:
            display_path = "..." + path[-37:]
    
        menu.add_command(label=f"Path: {display_path}", state="disabled")
        menu.add_separator()
    
        menu.add_command(label="Reload", command=self.load_files)
    
        # Back and forward navigation disabled if at ends
        if self.history_index > 0:
            menu.add_command(label="Back", command=lambda: self.navigate_history(-1))
        else:
            menu.add_command(label="Back", state="disabled")
    
        if self.history_index < len(self.history) - 1:
            menu.add_command(label="Forward", command=lambda: self.navigate_history(1))
        else:
            menu.add_command(label="Forward", state="disabled")
    
        # Parent folder shortcut
        parent = os.path.dirname(self.current_path.rstrip(os.sep))
        if parent and parent != self.current_path:
            menu.add_command(label="Go to Parent Folder", command=lambda: self.change_directory(parent))
        else:
            menu.add_command(label="Go to Parent Folder", state="disabled")
    
        menu.tk_popup(event.x_root, event.y_root)
    


    def on_right_click(self, event):
        # Placeholder for right-click; you could implement context menu here
        pass

if __name__ == "__main__":
    app = SimpleFileManager()
    app.mainloop()
