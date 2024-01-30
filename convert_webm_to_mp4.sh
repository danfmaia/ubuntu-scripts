#!/bin/bash

for file in *.webm; do
    if [ -f "$file" ]; then
        filename="${file%.*}"
        ffmpeg -i "$file" -vf "scale=trunc(iw/2)*2:-2" "${filename}.mp4"
    fi
done
