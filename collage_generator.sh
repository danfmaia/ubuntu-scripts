#!/bin/bash

# Directory for output files
output_dir="./output"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Initialize counter for output file names
output_counter=1

# Find all image files (both JPEG and PNG formats) in the current directory, excluding the output directory
# and read them into an array
readarray -t images < <(find . -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' \) ! -path "./output/*" | sort)

# Process images in batches of 6
for ((i=0; i<${#images[@]}; i+=6)); do
    # Select a batch of up to 6 images, handling spaces in filenames
    batch=("${images[@]:i:6}")

    # Check if the batch is empty
    if [ ${#batch[@]} -eq 0 ]; then
        break
    fi

    # Determine the output format based on the presence of .png files
    output_format="jpg"
    for img in "${batch[@]}"; do
        if [[ $img == *.png ]]; then
            output_format="png"
            break
        fi
    done

    # Build the montage command dynamically
    montage -tile 3x2 -geometry +5+5 -background yellow "${batch[@]}" "${output_dir}/output${output_counter}.${output_format}"

    # Check for errors in montage command
    if [ $? -ne 0 ]; then
        echo "Error: Montage command failed on batch $output_counter"
        exit 1
    fi

    # Increment the output file counter
    ((output_counter++))
done
