#!/usr/bin/env bash

set -u

echo "=========================================="
echo " MPEG-2 Video Converter"
echo "=========================================="
echo

# Check FFmpeg
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "ERROR: ffmpeg was not found."
    echo "Install it with:"
    echo "    sudo apt install ffmpeg"
    exit 1
fi

echo "FFmpeg found:"
ffmpeg -version | head -n 1
echo

# Determine input
if [ "$#" -eq 0 ]; then
    echo "ERROR: No input was supplied."
    echo
    echo "Usage:"
    echo "    $0 video.mp4"
    echo "    $0 video.webm"
    echo "    $0 /path/to/folder"
    exit 1
fi

INPUT="$1"

# Output directory
OUTDIR="mpeg2-output"
mkdir -p "$OUTDIR"

convert_file() {
    local INPUT_FILE="$1"

    if [ ! -f "$INPUT_FILE" ]; then
        echo "ERROR: File does not exist:"
        echo "  $INPUT_FILE"
        return 1
    fi

    local BASENAME
    BASENAME="$(basename "$INPUT_FILE")"

    local STEM
    STEM="${BASENAME%.*}"

    local OUTPUT_FILE="$OUTDIR/${STEM}.mpg"

    echo
    echo "------------------------------------------"
    echo "Input:"
    echo "  $INPUT_FILE"
    echo
    echo "Output:"
    echo "  $OUTPUT_FILE"
    echo "------------------------------------------"
    echo

    ffmpeg \
        -hide_banner \
        -i "$INPUT_FILE" \
        -map 0:v:0 \
        -map 0:a:0? \
        -vf "scale=1280:720:force_original_aspect_ratio=decrease,setsar=1,format=yuv420p" \
        -c:v mpeg2video \
        -b:v 7000k \
        -maxrate 9000k \
        -bufsize 1835k \
        -g 12 \
        -bf 2 \
        -c:a mp2 \
        -b:a 192k \
        -ar 48000 \
        -ac 2 \
        -f mpeg \
        "$OUTPUT_FILE"

    if [ "$?" -eq 0 ]; then
        echo
        echo "SUCCESS!"
        echo "Created:"
        echo "  $OUTPUT_FILE"
    else
        echo
        echo "ERROR: FFmpeg failed for:"
        echo "  $INPUT_FILE"
        return 1
    fi
}

# If the argument is a directory, process supported files.
if [ -d "$INPUT" ]; then

    echo "Input directory:"
    echo "  $INPUT"
    echo

    found=0

    while IFS= read -r -d '' FILE; do
        found=1
        convert_file "$FILE" || exit 1
    done < <(
        find "$INPUT" -maxdepth 1 -type f \
        \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' \
           -o -iname '*.mov' -o -iname '*.avi' \) \
        -print0
    )

    if [ "$found" -eq 0 ]; then
        echo "ERROR: No supported video files found in:"
        echo "  $INPUT"
        exit 1
    fi

else
    # Single file
    convert_file "$INPUT" || exit 1
fi

echo
echo "=========================================="
echo " Conversion complete."
echo " Output directory:"
echo "   $OUTDIR"
echo "=========================================="
