import tkinter as tk
from tkinter import scrolledtext
from tkinter import simpledialog
import subprocess
import json
import os
import threading

# -----------------------------
# Config
# -----------------------------
MODEL_NAME = "deepseek-r1:7b"
HISTORY_FILE = "chat_history.json"

# Colors
BG_COLOR = "#1e1e1e"
FG_COLOR = "#dcdcdc"
USER_BUBBLE = "#2d6acc"
AI_BUBBLE = "#44475a"
THINKING_COLOR = "#ffcc00"

# Load chat history
if os.path.exists(HISTORY_FILE):
    with open(HISTORY_FILE, "r") as f:
        chat_history = json.load(f)
else:
    chat_history = []

# -----------------------------
# Functions
# -----------------------------
def send_message():
    user_msg = entry.get().strip()
    if not user_msg:
        return
    entry.delete(0, tk.END)
    add_message("You", user_msg, USER_BUBBLE)
    root.update_idletasks()

    # Show thinking indicator
    thinking_label.config(text="DeepSeek is thinking...")
    root.update_idletasks()

    # Run in a thread to avoid freezing GUI
    threading.Thread(target=get_ai_response, args=(user_msg,)).start()

def get_ai_response(user_msg):
    try:
        result = subprocess.run(
            ["ollama", "run", MODEL_NAME],
            input=user_msg.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=120
        )
        ai_msg = result.stdout.decode().strip()
        if not ai_msg:
            ai_msg = "[No response]"
    except Exception as e:
        ai_msg = f"[Error: {str(e)}]"

    # Hide thinking indicator
    thinking_label.config(text="")

    add_message("DeepSeek R1", ai_msg, AI_BUBBLE)

    # Save chat history
    chat_history.append({"role": "user", "content": user_msg})
    chat_history.append({"role": "assistant", "content": ai_msg})
    with open(HISTORY_FILE, "w") as f:
        json.dump(chat_history, f, indent=2)

def add_message(sender, msg, color):
    text_area.configure(state="normal")
    bubble = f"{sender}:\n{msg}\n\n"
    text_area.insert(tk.END, bubble)
    text_area.tag_add(sender, f"end-{len(bubble)}c", tk.END)
    text_area.tag_config(sender, background=color, foreground=FG_COLOR, lmargin1=10, lmargin2=10, rmargin=10)
    text_area.configure(state="disabled")
    text_area.yview(tk.END)

def load_history():
    for msg in chat_history:
        sender = "You" if msg["role"] == "user" else "DeepSeek R1"
        color = USER_BUBBLE if msg["role"] == "user" else AI_BUBBLE
        add_message(sender, msg["content"], color)

# -----------------------------
# GUI
# -----------------------------
root = tk.Tk()
root.title("DeepSeek R1 ^")
root.geometry("800x700")
root.configure(bg=BG_COLOR)

# Sidebar for sessions (just placeholder for now)
sidebar = tk.Frame(root, width=150, bg="#2a2a2a")
sidebar.pack(side=tk.LEFT, fill=tk.Y)
tk.Label(sidebar, text="Chats", bg="#2a2a2a", fg=FG_COLOR, font=("Helvetica", 14)).pack(pady=10)

# Chat display
text_area = scrolledtext.ScrolledText(root, wrap=tk.WORD, state="disabled", font=("Helvetica", 12),
                                      bg=BG_COLOR, fg=FG_COLOR, bd=0, highlightthickness=0)
text_area.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)

# Thinking indicator
thinking_label = tk.Label(root, text="", fg=THINKING_COLOR, bg=BG_COLOR, font=("Helvetica", 12))
thinking_label.pack(side=tk.TOP, pady=2)

# Entry
entry_frame = tk.Frame(root, bg=BG_COLOR)
entry_frame.pack(side=tk.BOTTOM, fill=tk.X, padx=5, pady=5)

entry = tk.Entry(entry_frame, font=("Helvetica", 12), bg="#2e2e2e", fg=FG_COLOR, insertbackground=FG_COLOR)
entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0,5))
entry.bind("<Return>", lambda event: send_message())

send_btn = tk.Button(entry_frame, text="Send", command=send_message, bg="#2e2e2e", fg=FG_COLOR)
send_btn.pack(side=tk.RIGHT)

# Load previous chat
load_history()

root.mainloop()

