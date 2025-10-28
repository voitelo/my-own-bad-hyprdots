#!/usr/bin/env bash
set -euo pipefail

# tiktok-comments — universal sassy Arch wrapper

INSULTS=(
  "bro, even your browser history is cleaner than your code"
  "this package isn’t here, kinda like your life choices"
  "aur? more like Are U Really trying this hard?"
  "stop asking me to work, go touch some grass or something"
  "404: competence not found. try again, maybe?"
  "you tried, and failed, spectacularly. again. amazing."
  "did you even read the wiki? or was that too much effort?"
  "i’d explain, but your brain might explode"
  "pro tip: screaming at me won’t make the package appear"
  "your typing speed is faster than your ability to understand"
  "did you think this would work? cute."
  "oh look, another mistake. color me shocked"
  "you’re basically asking me to solve your life problems too"
  "if ignorance was a package, you’d be version 10.0"
  "procrastination called, it wants its champion back"
  "bruh, installing a package isn’t a personality upgrade"
  "go outside, the sun called, it misses you"
  "your CPU runs cooler than your logic, and that’s sad"
  "I could install it, but I’m still offended by your choices"
  "this package is missing, much like your sense of planning"
  "syfm? sybau? what is even happening in your brain right now?"
  "did you just type random letters and call it a flag? impressive"
  "TikTok called, it wants your comment section back"
)

rand_insult() {
  echo "${INSULTS[$RANDOM % ${#INSULTS[@]}]}"
}

have() { command -v "$1" >/dev/null 2>&1; }

need_root() {
  if [[ $EUID -ne 0 ]]; then
    if have sudo; then
      echo sudo
    else
      echo "you don’t even have sudo. uninstall yourself." >&2
      exit 1
    fi
  fi
}

sudo_cmd=$(need_root)

# --- parse arguments ---
operation=""
flags=()
pkgs=()

for arg in "$@"; do
  if [[ $arg == -* && -z "$operation" ]]; then
    operation="$arg"   # first - argument is the operation
  elif [[ $arg == -* ]]; then
    flags+=("$arg")    # subsequent flags
  else
    pkgs+=("$arg")
  fi
done

# --- handle system update using yay for full repo + AUR ---
if [[ "$operation" == "-Syu" || "$operation" == "-Su" || "$operation" == "-Syyu" ]]; then
  if ! have yay; then
    echo "[tiktok-comments] no yay found, install yay first, genius" >&2
    exit 1
  fi
  echo "[tiktok-comments] Updating system using yay? You must love chaos, psychopath."
  if $sudo_cmd yay -Syu "${flags[@]}"; then
    echo "[tiktok-comments] system update complete. Your OS is slightly less embarrassing now."
  else
    echo "[tiktok-comments] $(rand_insult)" >&2
    exit 1
  fi
  exit 0
fi

# --- if no operation, default to install ---
if [[ -z "$operation" ]]; then
  operation="-S"
fi

# --- handle installs only ---
if [[ "$operation" == "-S" || "$operation" == "-Si" ]]; then
  repo_pkgs=()
  aur_pkgs=()
  failed=()

  for pkg in "${pkgs[@]}"; do
    if pacman -Si -- "$pkg" >/dev/null 2>&1; then
      repo_pkgs+=("$pkg")
    else
      aur_pkgs+=("$pkg")
    fi
  done

  # --- install repo packages ---
  if (( ${#repo_pkgs[@]} > 0 )); then
    echo "[tiktok-comments] Using pacman? Real cute, just quit Arch already, dumbass."
    if $sudo_cmd pacman -S --needed "${repo_pkgs[@]}" "${flags[@]}"; then
      for p in "${repo_pkgs[@]}"; do
        echo "[tiktok-comments] installed ${p}. go flex or cry, your choice."
      done
    else
      echo "[tiktok-comments] $(rand_insult)" >&2
      failed+=("${repo_pkgs[@]}")
    fi
  fi

  # --- install AUR packages ---
  if (( ${#aur_pkgs[@]} > 0 )); then
    if ! have yay; then
      echo "[tiktok-comments] no yay installed, can't build AUR: ${aur_pkgs[*]}" >&2
      failed+=("${aur_pkgs[@]}")
    else
      echo "[tiktok-comments] Using yay? What are you? A psychopath?"
      if yay -S --needed "${aur_pkgs[@]}" "${flags[@]}"; then
        for p in "${aur_pkgs[@]}"; do
          echo "[tiktok-comments] yay! ${p} installed. celebrate like a human."
        done
      else
        echo "[tiktok-comments] $(rand_insult)" >&2
        failed+=("${aur_pkgs[@]}")
      fi
    fi
  fi

  if (( ${#failed[@]} > 0 )); then
    echo "[tiktok-comments] $(rand_insult)" >&2
    echo "[tiktok-comments] failed on: ${failed[*]}" >&2
    exit 1
  fi

  echo "[tiktok-comments] all done. your computer is less sad now. you're welcome."
  exit 0
fi

# --- for all other pacman operations, forward with sass ---
echo "[tiktok-comments] executing pacman command, let's see what you broke this time"
if $sudo_cmd pacman "$operation" "${flags[@]}" "${pkgs[@]}"; then
  echo "[tiktok-comments] pacman did its thing. maybe you learned something?"
else
  echo "[tiktok-comments] $(rand_insult)" >&2
  exit 1
fi
