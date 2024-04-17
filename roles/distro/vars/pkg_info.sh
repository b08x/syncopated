#!/usr/bin/env bash


function process_file() {
    local filename=$1
    if [ -f "$filename" ]; then
        while IFS= read -r line; do
            echo "$line"
            # Add your processing logic here
        done < "$filename"
    else
        echo "File not found: $filename"
    fi
}


# paru -Si $pkg | grep -E '^Name' | choose --field-separator ': ' 1
# paru -Si $pkg | grep -E '^Description' | choose --field-separator ': ' 1
# paru -Si $pkg | grep -E '^URL' | choose --field-separator ': ' 1
# paru -Si $pkg | grep -E '^Groups' | choose --field-separator ': ' 1


#
#
# remove '-git' before search repology

process_file /tmp/pkgs.txt
