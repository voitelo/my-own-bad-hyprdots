#!/usr/bin/env bash
set -e

# --------------------------
# Parse input
# --------------------------
input_file="$1"

# Default path handling
if [[ "$input_file" == ~/* ]]; then
    input_file="$HOME/${input_file#~/}"
elif [[ "$input_file" != /* ]]; then
    input_file="$HOME/$input_file"
fi

if [ ! -f "$input_file" ]; then
    echo "Error: File not found."
    exit 1
fi

# --------------------------
# Ask for output format
# --------------------------
read -rp "Enter desired output format (e.g., mp3, wav): " format
filename=$(basename -- "$input_file")
name="${filename%.*}"
output_file="${name}.${format}"

# --------------------------
# Convert
# --------------------------
ffmpeg -i "$input_file" -c:a copy "$output_file" 2>/dev/null || ffmpeg -i "$input_file" "$output_file"

echo "✅ Conversion complete: $output_file"

