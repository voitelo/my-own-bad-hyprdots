#!/bin/bash

echo "first we are gonna delete orphaned useless packages"
sudo pacman -Rns $(pacman -Qdtq) --noconfirm
yay -Rns $(yay -Qdtq) --noconfirm
flatpak remove --unused
echo "now we are gonna clear da caches"
sudo pacman -Scc --noconfirm
yay -Scc --noconfirm
flatpak remove --delete-data
echo "now we are gonna update"
sudo pacman -Syu --noconfirm
yay -Syu --noconfirm
flatpak update
echo "your system is now clean and updated!!"
