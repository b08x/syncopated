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
    echo "   ctrl-r                 select task"
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

declare -rx GUM_SPIN_SPINNER="pulse"

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
            --layout="reverse" \
            --header="Select Playbook" \
            --tac \
            --prompt="Playbook > ")
}

# Function to select hosts
select_hosts() {
    selected_hosts=$(awk '/^\[/ {gsub(/[\[\]]/, ""); print}' inventory.ini | \
        fzf --multi \
            --layout="reverse" \
            --header="Select Host(s)" \
            --prompt="Hosts > ")
}

# Function to select tags
select_tags() {
    if [[ -n "$selected_playbook" ]]; then
        selected_tags=$(ansible-playbook -i inventory.ini "$selected_playbook" --list-tags | \
            grep "TASK TAGS" | cut -d':' -f2 | tr '[' ' ' | tr ']' ' ' | tr ',' '\n' | \
            fzf --multi \
                --layout="reverse" \
                --header="Select Tags" \
                --prompt="Tags > ")
    else
        echo "Please select a playbook first."
    fi
}

# Function to select task
select_task() {
    if [[ -n "$selected_playbook" ]]; then
        # Create a temporary file to store all tasks
        temp_file=$(mktemp)
        find roles/ -type f -wholename "**/tasks/*.yml" -exec bash -c 'extract_tasks "$0"' {} \; > "$temp_file"

        selected_task=$(cat "$temp_file" | \
            fzf --preview 'line=$(echo {} | cut -d: -f2); file=$(echo {} | cut -d: -f1); bash -c "preview_task \"$file\" \"$line\""' \
                --preview-window=right:50% \
                --tac \
                --layout="reverse" \
                --header="Select Task" \
                --prompt="Task > ")

        # Remove the temporary file
        rm "$temp_file"

        if [[ -n "$selected_task" ]]; then
            selected_task=$(echo "$selected_task" | cut -d: -f3-)
        fi
    else
        echo "Please select a playbook first."
    fi
}

reset_vars() {
  unset selected_playbook
  unset selected_hosts
  unset selected_tags
  unset selected_task
}

# Function to execute playbook
execute_playbook() {
    if [[ -z "$selected_playbook" ]]; then
        echo "Please select a playbook first."
        return
    fi

    command="ansible-playbook -C -i inventory.ini $selected_playbook"

    if [[ -n "$selected_hosts" ]]; then
        command+=" --limit $selected_hosts"
    fi

    if [[ -n "$selected_tags" ]]; then
        command+=" --tags $selected_tags"
    # else
    #     command+=" --tags always"
    fi

    if [[ -n "$selected_task" ]]; then
        command+=" --start-at-task '$selected_task'"
    fi

    command+=" -e 'gather_facts=true'"

    # Display confirmation with gum
    echo "Selected options:"
    echo "Playbook: $selected_playbook"
    echo "Hosts: $selected_hosts"
    echo "Tags: $selected_tags"
    echo "Task: $selected_task"
    echo
    echo "Command to execute:"
    echo "$command"
    echo

    if gum confirm "Do you want to execute this playbook?"; then
        echo "Executing: $command"
        echo "Please wait while the playbook runs..."
        sleep 0.5
        tput clear cup 5

        # # Execute the command and pipe output to gum pager
        # eval "$command" 2>&1 | gum pager
        # Execute the command and pipe output to Ruby script
        eval "$command" 2>&1 | ruby -e '
            STDIN.each_line do |line|
              # puts line if line.match(/TASK/)
              input = line.chomp if line.match(/TASK/)
                unless input.nil?
                  input.each_char do |char|
                    print "\e[34m#{char}\e[0m"
                    $stdout.flush
                    sleep 0.02
                  end
                  puts "\n"
                end
              res = line.chomp if line.match(/PLAY RECAP|ok\:|ok\=|changed\:/)
              unless res.nil?
                puts "\e[32m#{res.strip.chomp}\e[0m"
              end
            end
            puts "all set!"
            sleep 3
        '
        reset_vars
    else
        echo "Execution cancelled."
    fi
}
# Export functions so they're available to subshells
export -f extract_tasks
export -f preview_task

# Main menu
while true; do
    action=$(echo -e "Select Playbook\nSelect Host(s)\nSelect Tags\nSelect Task\nExecute Playbook\nExit" | \
        fzf --header="Ansible Menu" \
            --layout="reverse" \
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
