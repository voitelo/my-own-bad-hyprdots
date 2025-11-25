#!/usr/bin/env bash
set -e

# --------------------------
# Detect dependencies
# --------------------------
HAS_LIBREOFFICE=0
HAS_PANDOC=0
HAS_IMAGEMAGICK=0
IMG_CMD=""

# LibreOffice (Flatpak only)
if flatpak info org.libreoffice.LibreOffice >/dev/null 2>&1; then
    HAS_LIBREOFFICE=1
else
    echo "⚠️  Heads-up: LibreOffice must be installed via Flatpak for document conversion."
fi

# Pandoc
command -v pandoc >/dev/null 2>&1 && HAS_PANDOC=1

# ImageMagick detection
if command -v magick >/dev/null 2>&1; then
    HAS_IMAGEMAGICK=1
    IMG_CMD="magick"
elif command -v convert >/dev/null 2>&1; then
    HAS_IMAGEMAGICK=1
    IMG_CMD="convert"
fi

# --------------------------
# Build available formats
# --------------------------
DOC_FORMATS=()
TEXT_FORMATS=()
IMG_FORMATS=()

[ $HAS_LIBREOFFICE -eq 1 ] && DOC_FORMATS=(docx pdf odt pptx xlsx)
[ $HAS_PANDOC -eq 1 ] && TEXT_FORMATS=(txt md pdf docx)
[ $HAS_IMAGEMAGICK -eq 1 ] && IMG_FORMATS=(png jpg jpeg bmp gif tiff)

ALL_FORMATS=("${DOC_FORMATS[@]}" "${TEXT_FORMATS[@]}" "${IMG_FORMATS[@]}")

if [ ${#ALL_FORMATS[@]} -eq 0 ]; then
    echo "⚠️  Warning: No dependencies found. Install Flatpak LibreOffice, Pandoc, or ImageMagick."
fi

# Show available formats
echo "You can convert files to the following formats (based on installed tools):"
printf "  %s\n" "${ALL_FORMATS[@]}"
echo

# --------------------------
# Get input file
# --------------------------
read -rp "Enter the path to the file you want to convert: " input_file

# Expand paths
if [[ "$input_file" == ~/* ]]; then
    input_file="$HOME/${input_file#~/}"
elif [[ "$input_file" != /* ]]; then
    input_file="$HOME/$input_file"
fi

if [ ! -f "$input_file" ]; then
    echo "Error: File not found: $input_file"
    exit 1
fi

filename=$(basename -- "$input_file")
name="${filename%.*}"
ext="${filename##*.}"
ext_lc=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

# Ask target format
read -rp "Enter desired output format (extension only): " format
output_file="${name}.${format}"

# --------------------------
# Conversion functions
# --------------------------
convert_document() {
    if [ $HAS_LIBREOFFICE -eq 1 ]; then
        flatpak run org.libreoffice.LibreOffice --headless --convert-to "$format" --outdir "$(dirname "$input_file")" "$input_file" 2>/dev/null || echo "⚠️  Document conversion failed."
        mv "$(dirname "$input_file")/${name}.${format}" "$output_file" 2>/dev/null || true
    else
        echo "⚠️  Cannot convert documents: LibreOffice (Flatpak) not found."
    fi
}

convert_text() {
    if [ $HAS_PANDOC -eq 1 ]; then
        pandoc "$input_file" -o "$output_file" 2>/dev/null || echo "⚠️  Text conversion failed."
    else
        echo "⚠️  Cannot convert text files: Pandoc not found."
    fi
}

convert_image() {
    if [ $HAS_IMAGEMAGICK -eq 1 ]; then
        $IMG_CMD "$input_file" "$output_file" 2>/dev/null || echo "⚠️  Image conversion failed."
    else
        echo "⚠️  Cannot convert images: ImageMagick not found."
    fi
}

# Determine conversion type
case "$ext_lc" in
    doc|docx|odt|ppt|pptx|xls|xlsx)
        convert_document
        ;;
    txt|md)
        convert_text
        ;;
    png|jpg|jpeg|bmp|gif|tiff)
        convert_image
        ;;
    *)
        echo "⚠️  Unknown or unsupported file type: $ext_lc"
        ;;
esac

# --------------------------
# Verify output file type
# --------------------------
if command -v file >/dev/null 2>&1; then
    real_type=$(file --brief --mime-type "$output_file")
    case "$format" in
        pdf)
            [[ "$real_type" == "application/pdf" ]] || echo "⚠️  Warning: Output file may not be a proper PDF."
            ;;
        docx)
            [[ "$real_type" == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ]] || echo "⚠️  Warning: Output file may not be a proper DOCX."
            ;;
        odt)
            [[ "$real_type" == "application/vnd.oasis.opendocument.text" ]] || echo "⚠️  Warning: Output file may not be a proper ODT."
            ;;
        txt|md)
            [[ "$real_type" == "text/plain" ]] || echo "⚠️  Warning: Output file may not be proper plain text."
            ;;
        png)
            [[ "$real_type" == "image/png" ]] || echo "⚠️  Warning: Output file may not be a proper PNG."
            ;;
        jpg|jpeg)
            [[ "$real_type" == "image/jpeg" ]] || echo "⚠️  Warning: Output file may not be a proper JPEG."
            ;;
        bmp)
            [[ "$real_type" == "image/bmp" ]] || echo "⚠️  Warning: Output file may not be a proper BMP."
            ;;
        gif)
            [[ "$real_type" == "image/gif" ]] || echo "⚠️  Warning: Output file may not be a proper GIF."
            ;;
        tiff)
            [[ "$real_type" == "image/tiff" ]] || echo "⚠️  Warning: Output file may not be a proper TIFF."
            ;;
        *)
            echo "ℹ️  Unable to verify type for .$format files."
            ;;
    esac
else
    echo "ℹ️  'file' command not found, skipping type verification."
fi

echo "✅ Conversion attempt finished: $output_file (check if conversion succeeded)"

