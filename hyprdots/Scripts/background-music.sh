#!/bin/bash
# File: loop_minecraft_music.sh
# Loops selected Minecraft tracks in order, slightly louder

MUSIC_DIR="$HOME/Moosic/"
TRACKS=(
  "01 - Key.ogg"
  "02 - Door.ogg"
  "03 - Subwoofer Lullaby.ogg"
  "06 - Moog City.ogg"
  "07 - Haggstrom.ogg"
  "08 - Minecraft.ogg"
  "10 - Équinoxe.ogg"
  "12 - Dry Hands.ogg"
  "13 - Wet Hands.ogg"
  "14 - Clark.ogg"
  "15 - Chris.ogg"
  "17 - Excuse.ogg"
  "18 - Sweden.ogg"
  "20 - Dog.ogg"
  "21 - Danny.ogg"
  "22 - Beginning.ogg"
  "23 - Droopy Likes Ricochet.ogg"
  "24 - Droopy Likes Your Face.ogg"
)

# Infinite loop
while true; do
  for track in "${TRACKS[@]}"; do
    mpv --no-video --really-quiet --volume=125 "$MUSIC_DIR/$track"
  done
done
