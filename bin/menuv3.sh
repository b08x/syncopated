#!/bin/bash

version=1.0.0
usage="usage: ansible_menu [-h] [-v]"

display_help() {
    echo
    echo "╔════════════════════╗"
    echo "║░   Ansible Menu   ░║"
    echo "╚════════════════════╝"
    echo
    echo "$usage"
    echo
    echo "   -h, --help              show this help"
    echo "   -v, --version           get version"
    echo
    echo "   ctrl-space             toggle selection"
    echo "   ctrl-l                 clear query"
    echo "   ctrl-p                 toggle preview"
    echo "   ctrl-w                 toggle preview wrap"
    echo "   shift-up               preview up"
    echo "   shift-down             preview down"
    echo "   shift-left             preview page up"
    echo "   shift-right            preview page down"
    echo "   enter                  run ansible-playbook from selected task"
    echo "   esc                    exit"
    echo
    exit 0
}

while getopts hv option
do
    case "${option}" in
        h | help)
            display_help
            ;;
        v | version)
            echo "Ansible Menu v$version"
            exit 0
            ;;
        *)
            echo $usage
            exit 1
            ;;
    esac
done

# Function to extract tasks from a file
extract_tasks() {
    awk '/^- name:/ {print FILENAME ":" NR ":" substr($0, index($0,$3))}' "$1"
}

# Function to preview task details
preview_task() {
    local file="$1"
    local line="$2"
    sed -n "${line},/^$/p" "$file"
}

# Colors
bg="#282c34"
fg="#abb2bf"
header="#61afef"
selected="#c678dd"
preview_bg="#21252b"
preview_fg="#98c379"

# Export functions so they're available to subshells
export -f extract_tasks
export -f preview_task

# Create a temporary file to store all tasks
temp_file=$(mktemp)
find roles/ -type f -name "*.yml" -exec bash -c 'extract_tasks "$0"' {} \; > "$temp_file"

# Main menu for roles and tasks
selected_task=$(cat "$temp_file" | \
    fzf --preview 'line=$(echo {} | cut -d: -f2); file=$(echo {} | cut -d: -f1); bash -c "preview_task \"$file\" \"$line\""' \
        --preview-window=right:60% \
        --header=$'╔════════════════════╗\n║░  Ansible Tasks   ░║\n╚════════════════════╝\n' \
        --prompt="Select a task > " \
        --pointer='▶' \
        --border=rounded \
        --bind 'ctrl-w:toggle-preview-wrap' \
        --bind 'ctrl-l:clear-query' \
        --bind 'ctrl-p:toggle-preview' \
        --color="bg:$bg,fg:$fg,header:$header,pointer:$selected,preview-bg:$preview_bg,preview-fg:$preview_fg")

# Remove the temporary file
rm "$temp_file"

if [[ -n "$selected_task" ]]; then
    # Extract task name (remove file path and line number)
    task_name=$(echo "$selected_task" | cut -d: -f3-)

    # Run ansible-playbook
    echo "Running ansible-playbook starting from task: $task_name"
    ansible-playbook -C -i inventory.ini playbooks/full.yml --start-at-task "$task_name"
else
    echo "No task selected."
fi
