#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <video_filename> <scale>"
  exit 1
fi

# Get the input filename and scale from the arguments
VIDEO_FILE="$1"
SCALE="$2"

# Get the output filename by replacing the extension with .gif
OUTPUT_FILE="${VIDEO_FILE%.*}.gif"

# Check if the input video file exists
if [ ! -f "$VIDEO_FILE" ]; then
  echo "Error: Video file '$VIDEO_FILE' not found."
  exit 1
fi

# Generate the palette
echo "Generating color palette for GIF..."
ffmpeg -i "$VIDEO_FILE" -vf "fps=10,scale=${SCALE}:-1:flags=lanczos,palettegen" -y palette.png

# Check if palette generation succeeded
if [ ! -f "palette.png" ]; then
  echo "Error: Failed to generate the color palette."
  exit 1
fi

# Create the GIF using the palette
echo "Converting video to GIF..."
ffmpeg -i "$VIDEO_FILE" -i palette.png -lavfi "fps=10,scale=${SCALE}:-1:flags=lanczos [x]; [x][1:v] paletteuse" -y "$OUTPUT_FILE"

# Check if the GIF creation succeeded
if [ -f "$OUTPUT_FILE" ]; then
  echo "GIF created successfully: $OUTPUT_FILE"
else
  echo "Error: Failed to create the GIF."
  exit 1
fi

# Remove the temporary palette file
rm -f palette.png

echo "Temporary palette file removed."
