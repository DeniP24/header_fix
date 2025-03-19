#!/bin/bash

# Input files
file1="damaged_headers.txt"
file2="fixed_4tstamps.txt"
output="matched.txt"

# Clear or create output file
> "$output"

while read -r line; do
    first_field=$(echo "$line" | awk '{print $1}')
    fil_name=$(basename "$first_field")
    echo $fil_name
    grep -F "$fil_name" fixed_4tstamps.txt | awk -v original="$line" '{print $0, original}' >> batchmatched.txt
done < 2batch.txt

echo "Matching completed. Results saved to $output"