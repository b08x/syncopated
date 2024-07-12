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
    echo "   ctrl-p                 select playbook"
    echo "   ctrl-h                 select host(s)"
    echo "   ctrl-t                 select tags"
    echo "   ctrl-r                 select task (role)"
    echo "   ctrl-x                 execute playbook"
    echo "   ctrl-c                 exit"
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

# Colors
bg="#282c34"
fg="#abb2bf"
header="#61afef"
selected="#c678dd"
preview_bg="#21252b"
preview_fg="#98c379"

# Variables to store selections
selected_playbook=""
selected_hosts=""
selected_tags=""
selected_task=""

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

# Function to select playbook
select_playbook() {
    selected_playbook=$(find playbooks/ -name "*.yml" | \
        fzf --preview 'bat --style=numbers --color=always {}' \
            --preview-window=right:60% \
            --header="Select Playbook" \
            --prompt="Playbook > ")
}

# Function to select hosts
select_hosts() {
    selected_hosts=$(awk '/^\[/ {gsub(/[\[\]]/, ""); print}' inventory.ini | \
        fzf --multi \
            --header="Select Host(s)" \
            --prompt="Hosts > ")
}

# Function to select tags
select_tags() {
    if [[ -n "$selected_playbook" ]]; then
        selected_tags=$(ansible-playbook "$selected_playbook" --list-tags | \
            grep "TASK TAGS" | cut -d':' -f2 | tr '[' ' ' | tr ']' ' ' | tr ',' '\n' | \
            fzf --multi \
                --header="Select Tags" \
                --prompt="Tags > ")
    else
        echo "Please select a playbook first."
    fi
}

# Function to select task (role)
select_task() {
    # Create a temporary file to store all tasks
    temp_file=$(mktemp)
    find roles/ -type f -name "*.yml" -exec bash -c 'extract_tasks "$0"' {} \; > "$temp_file"

    selected_task=$(cat "$temp_file" | \
        fzf --preview 'line=$(echo {} | cut -d: -f2); file=$(echo {} | cut -d: -f1); bash -c "preview_task \"$file\" \"$line\""' \
            --preview-window=right:60% \
            --header="Select Task" \
            --prompt="Task > ")

    # Remove the temporary file
    rm "$temp_file"

    if [[ -n "$selected_task" ]]; then
        selected_task=$(echo "$selected_task" | cut -d: -f3-)
    fi
}

# Function to execute playbook
execute_playbook() {
    if [[ -z "$selected_playbook" ]]; then
        echo "Please select a playbook first."
        return
    fi

    command="ansible-playbook -C $selected_playbook"

    if [[ -n "$selected_hosts" ]]; then
        command+=" --limit $selected_hosts"
    fi

    if [[ -n "$selected_tags" ]]; then
        command+=" --tags $selected_tags"
    else
        # If no specific tags are selected, always include 'always' tag
        command+=" --tags always"
    fi

    if [[ -n "$selected_task" ]]; then
        # Instead of --start-at-task, we'll use tags
        task_tag=$(echo "$selected_task" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
        command+=" --tags always,setup,$task_tag"
    fi

    # Always gather facts
    command+=" -e 'gather_facts=true'"

    echo "Executing: $command"
    eval "$command"
}

# Export functions so they're available to subshells
export -f extract_tasks
export -f preview_task

# Main menu
while true; do
    action=$(echo -e "Select Playbook\nSelect Host(s)\nSelect Tags\nSelect Task\nExecute Playbook\nExit" | \
        fzf --header="Ansible Menu" \
            --prompt="Action > ")

    case "$action" in
        "Select Playbook")
            select_playbook
            ;;
        "Select Host(s)")
            select_hosts
            ;;
        "Select Tags")
            select_tags
            ;;
        "Select Task")
            select_task
            ;;
        "Execute Playbook")
            execute_playbook
            ;;
        "Exit")
            exit 0
            ;;
    esac
done
