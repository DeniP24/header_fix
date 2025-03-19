#!/bin/bash

INPUT_FILE="excess.txt"
DAMAGED_FILE="excess.txt"

while IFS= read -r fullpath; do
    dir_path=$(dirname "$fullpath")
    Jpath=$(dirname "$dir_path")
    file_name=$(basename "$fullpath")
    if [[ -d "$Jpath" ]]; then
        # Initialize the flag for finding a valid file
        found_non_damaged=false
    
        # Find the first matching .fil file in Jpath/*/* that is not in INPUT_FILE
        while IFS= read -r file; do
            # Extract the filename without path
            filename=$(basename "$file")
            # Check if the file is NOT in damaged_headers.txt
            if ! grep -Fxq "$filename" "$INPUT_FILE"; then
                echo "$Jpath$filename" >> excess_replacement_headers.txt
                found_non_damaged=true
                break
            fi
        done < <(find "$Jpath"/*/* -type f -name "*.fil" 2>/dev/null)

        # If no non-damaged file was found, indicate that
        if ! $found_non_damaged; then
            echo "All files in $dir_path are in damaged"
            echo "No file found..." >> excess_replacement_headers.txt
        fi

    else
        echo "Directory $dir_path does not exist."
    fi
done < "$INPUT_FILE"


