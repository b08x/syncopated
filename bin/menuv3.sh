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
    echo "   ctrl-space             toggle role/task"
    echo "   ctrl-l                 clear query"
    echo "   ctrl-p                 toggle preview"
    echo "   ctrl-w                 toggle preview wrap"
    echo "   shift-up               preview up"
    echo "   shift-down             preview down"
    echo "   shift-left             preview page up"
    echo "   shift-right            preview page down"
    echo "   enter                  view selected role/task"
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

# Function to display the content of a file
preview_content() {
    local file="$1"
    if [[ -f "$file" ]]; then
        bat --style=numbers,changes --color=always "$file"
    else
        echo "Error: File not found: $file"
    fi
}

# Function to list tasks for a role
list_tasks() {
    local role="$1"
    local task_dir="roles/$role/tasks"
    if [[ -d "$task_dir" ]]; then
        find "$task_dir" -type f -printf "%P\n"
    else
        echo "No tasks found for role: $role"
    fi
}

# Colors
bg="#282c34"
fg="#abb2bf"
header="#61afef"
selected="#c678dd"
preview_bg="#21252b"
preview_fg="#98c379"

# Export functions so they're available to subshells
export -f preview_content
export -f list_tasks

# Main menu for roles
selected_role=$(find roles/ -maxdepth 1 -type d -printf "%P\n" | sed '1d' | fzf \
    --preview 'bash -c "list_tasks {}"' \
    --preview-window=right:50% \
    --header=$'╔════════════════════╗\n║░    Ansible Roles  ░║\n╚════════════════════╝\n' \
    --prompt="Select a role > " \
    --pointer='▶' \
    --border=rounded \
    --color="bg:$bg,fg:$fg,header:$header,pointer:$selected,preview-bg:$preview_bg,preview-fg:$preview_fg")

if [[ -n "$selected_role" ]]; then
    # Submenu for tasks
    selected_task=$(list_tasks "$selected_role" | fzf \
        --preview "bash -c 'preview_content roles/$selected_role/tasks/{}'" \
        --preview-window=right:60% \
        --header=$"╔════════════════════╗\n║░    Role Tasks    ░║\n╚════════════════════╝\n\nSelected Role: $selected_role\n" \
        --prompt="Select a task > " \
        --pointer='▶' \
        --border=rounded \
        --bind 'ctrl-w:toggle-preview-wrap' \
        --bind 'ctrl-l:clear-query' \
        --bind 'ctrl-p:toggle-preview' \
        --color="bg:$bg,fg:$fg,header:$header,pointer:$selected,preview-bg:$preview_bg,preview-fg:$preview_fg")

    if [[ -n "$selected_task" ]]; then
        # View the selected task
        less "roles/$selected_role/tasks/$selected_task"
    else
        echo "No task selected."
    fi
else
    echo "No role selected."
fi
