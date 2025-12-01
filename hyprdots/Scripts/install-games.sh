#!/bin/bash

# Ensure gum exists
if ! command -v gum >/dev/null 2>&1; then
  echo "gum is required but not installed."
  exit 1
fi

# Title
gum style --foreground 212 --border double --padding "1 2" --margin "1 2" \
  "Game Store Installer"

gum style "Pick a store to install:"

STORE=$(gum choose "Steam (Flatpak)" "Heroic (yay)" "Lutris (yay)" "Bottles (yay)" "Itch.io (yay)" "Cancel")

if [[ "$STORE" == "Cancel" ]]; then
  gum style --foreground 196 "Cancelled."
  exit 0
fi

gum style --bold --foreground 45 "Installing: $STORE"

# Function to install yay packages
install_yay() {
  PKG="$1"
  if ! command -v yay >/dev/null 2>&1; then
    gum style --foreground 196 "yay not found! Please install it first."
    exit 1
  fi
  gum spin --spinner line --title "Installing $PKG via yay..." -- \
    yay -S --noconfirm "$PKG"
}

case "$STORE" in
  "Steam (Flatpak)")
    gum style "Steam will be installed using Flatpak."
    gum spin --spinner line --title "Installing Steam..." -- \
      flatpak install -y flathub com.valvesoftware.Steam
    ;;

  "Heroic (yay)")
    install_yay "heroic-games-launcher-bin"
    ;;

  "Lutris (yay)")
    install_yay "lutris"
    ;;

  "Bottles (yay)")
    install_yay "bottles"
    ;;

  "Itch.io (yay)")
    install_yay "itch-setup-bin"
    ;;
esac

gum style --foreground 82 --bold "Done!"
gum style "Your selected game store has been installed."

