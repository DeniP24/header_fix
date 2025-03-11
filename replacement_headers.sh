#!/bin/bash

INPUT_FILE="1damaged_headers.txt_all"
DAMAGED_FILE="1damaged_headers.txt_all"

while IFS= read -r fullpath; do
    dir_path=$(dirname "$fullpath")
    file_name=$(basename "$fullpath")
    if [[ -d "$dir_path" ]]; then
        # Initialize the counter for finding a file not in damaged_headers.txt
        found_non_damaged=false
        while IFS= read -r file; do
            # Check if the file is NOT in damaged_headers.txt
            if [[ "$file" == *.fil ]] && ! grep -Fxq "$file" "$INPUT_FILE"; then
                echo "$file" >> replacement_headers.txt
                found_non_damaged=true
                break
            fi
        done < <(find "$dir_path" -type f)

        # If no non-damaged file was found, indicate that
        if ! $found_non_damaged; then
            echo "All files in $dir_path are in damaged"
        fi

    else
        echo "Directory $dir_path does not exist."
    fi
done < "$INPUT_FILE"


