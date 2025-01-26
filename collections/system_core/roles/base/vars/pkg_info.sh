#!/usr/bin/env bash


function process_file() {
    local filename=$1
    if [ -f "$filename" ]; then
        while IFS= read -r line; do
            name=$(paru -Si $line | grep -E '^Name' | choose --field-separator ': ' 1 || echo 'no name')

            desc=$(paru -Si $line | grep -E '^Description' | choose --field-separator ': ' 1 || echo 'no desc')

            url=$(paru -Si $line | grep -E '^URL' | choose --field-separator ': ' 1 || echo 'no url')
            # paru -Si $line | grep -E '^Groups' | choose --field-separator ': ' 1 || echo 'no group'
            echo "| ${name} | ${desc} |"
          done < "$filename"
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
