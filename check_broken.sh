#!/bin/bash
while read line; do
    if header "$line" -telescope | grep -Fxq 'Arecibo'; then
        echo "$line" >> damaged_headers.txt
    else
        echo "$line header intact"
    fi
done < "$1"

