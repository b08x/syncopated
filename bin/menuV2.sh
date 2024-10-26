#!/bin/bash

# --- Error Handling ---
ctrl_c() {
  echo "** End."
  sleep 0.1
  # tput clear
}
trap ctrl_c INT SIGINT SIGTERM ERR EXIT

# --- Colors ---
ALL_OFF="\e[1;0m"
BBOLD="\e[1;1m"
BLUE="${BBOLD}\e[1;34m"
GREEN="${BBOLD}\e[1;32m"
RED="${BBOLD}\e[1;31m"
YELLOW="${BBOLD}\e[1;33m"
export GUM_INPUT_WIDTH=0

DISTRO=$(lsb_release -si)

declare -rx ANSIBLE_HOME="${HOME}/.config/dotfiles"

# --- Display Function ---
say() {
  echo -e "${2}${1}${ALL_OFF}"
  sleep 1
}

message() {
  local message=$1
  gum style \
      --foreground 222 --border-foreground 240 --border normal \
      --align left --width 80 --margin "1 2" --padding "1 2" \
      "${message}"
}

version=1.0.0
usage="usage: ansible_menu [-h] [-v] [-x]"

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
    echo "   -x, --execute           execute live"
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

while getopts hvx option
do
    case "${option}" in
        h | help)
            display_help
            ;;
        v | version)
            echo "Ansible Menu v$version"
            exit 0
            ;;
        x | execute)
            declare -rx EXECUTE_MODE=True
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

view_log() {
  gum pager < file.log
}

# Function to select playbook
select_playbook() {
    selected_playbook=$(find "${ANSIBLE_HOME}/playbooks/" -name "*.yml" | \
        fzf --preview 'bat --style=numbers --color=always {}' \
            --preview-window=right:60% \
            --layout="reverse" \
            --header="Select Playbook" \
            --tac \
            --prompt="Playbook > ")
}

# Function to select hosts
select_hosts() {
    selected_hosts=$(awk '/^[^ ]/ {gsub(/[\[\]]/, ""); print}' $ANSIBLE_HOME/inventory.ini |uniq|choose 0|grep -Ev ':vars|=' | \
        choose -f ':' 0 | \
        fzf --multi \
            --layout="reverse" \
            --header="Select Host(s)" \
            --prompt="Hosts > "| \
        sd '\n' ',' | sd '  ' '')
}

# Function to select tags
select_tags() {
    if [[ -n "$selected_playbook" ]]; then
        selected_tags=$(ansible-playbook -i "${ANSIBLE_HOME}/inventory.ini" "$selected_playbook" --list-tags | \
            grep "TASK TAGS" | cut -d':' -f2 | tr '[' ' ' | tr ']' ' ' | tr ',' '\n' | \
            fzf --multi \
                --layout="reverse" \
                --header="Select Tags" \
                --prompt="Tags > "| \
            sd '\n' ',' | sd '  ' '')

        # selected_tags="${selected_tags%%*(  )}"

    else
        echo "Please select a playbook first."
    fi
}

# Function to select task
select_task() {
    if [[ -n "$selected_playbook" ]]; then
        # Create a temporary file to store all tasks
        temp_file=$(mktemp)
        find "${ANSIBLE_HOME}/roles/" -type f -wholename "**/tasks/*.yml" -exec bash -c 'extract_tasks "$0"' {} \; > "$temp_file"

        selected_task=$(cat "$temp_file" | \
            fzf --preview 'line=$(echo {} | cut -d: -f2); file=$(echo {} | cut -d: -f1); bash -c "preview_task \"$file\" \"$line\""' \
                --preview-window=right:50% \
                --color="bg:$bg,fg:$fg,header:$header,pointer:$selected,preview-bg:$preview_bg,preview-fg:$preview_fg" \
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


preview_command() {
  gum style \
      --foreground 212 --border-foreground 212 --border double \
      --align left --width 80 --margin "0 1" --padding "1 2" \
      "Selected options:" \
      "Playbook: $selected_playbook" \
      "Hosts: $selected_hosts" \
      "Tags: $selected_tags" \
      "Task: $selected_task" \
      "" \
      "Command to execute:" \
      "$command"
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

    if [[ $EXECUTE_MODE ]]; then
      command="ansible-playbook -i $ANSIBLE_HOME/inventory.ini $selected_playbook"
    else
      command="ansible-playbook -C -i $ANSIBLE_HOME/inventory.ini $selected_playbook"
    fi

    if [[ -n "$selected_hosts" ]]; then
        command+=" --limit ${selected_hosts%,}"
    fi

    if [[ -n "$selected_tags" ]]; then
        command+=" --tags '${selected_tags%,}'"
    # else
    #     command+=" --tags always"
    fi

    if [[ -n "$selected_task" ]]; then
        command+=" --start-at-task '$selected_task'"
    fi

    command+=" -e 'gather_facts=true'"
    # tput clear
    sleep 0.1

    preview_command

    if gum confirm "Do you want to execute this playbook?"; then
        message "Executing: $command"

        gum spin --spinner dot --title "Please wait while the thing loads..." -- sleep 5
        # tput clear cup 5

        # # Execute the command and pipe ou# tput to gum pager
        # eval "$command" 2>&1 | gum pager
        # Execute the command and pipe ou# tput to Ruby script
        eval "$command" 2>&1 | tee file.log | ruby -e '
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
              res = line.chomp if line.match(/ok\:|changed\:/)
              unless res.nil?
                puts "\e[32m#{res.strip.chomp}\e[0m"
                puts "\n"
              end
              cap = line.chomp if line.match(/PLAY RECAP|ok\=/)
              puts "\e[33m#{cap.strip.chomp}\e[0m\n" unless cap.nil?
            end
            puts "\n"
            sleep 3
        '
        gum confirm "You wanna see the logs?" && view_log

        gum confirm "Let's exit now ;)" && exit
    else
        echo "Execution cancelled."
    fi
}

welcome() {
  gum style \
      --foreground 250 --border-foreground 222 --border normal \
      --align center --width 80 --margin "1 2" --padding "2 4" \
      "Syncopated Linux v0.7.5 Demo"
}

introA() {
  local something=$1
  gum style \
    --height 5 --width 40 --margin "1 2" \
    --padding "1 5" \
    --border normal --border-foreground 57 \
    "asdasdsadasd"
}

introB() {
  local something=$1
  gum style \
    --height 5 --width 40 --margin "1 2" \
    --padding "1 4" \
    --border normal --border-foreground 57 \
    "hey"
}


tput clear
welcome
sleep 1

message "A set of roles for audio, desktop, development, and system configuration"
sleep 1

# MSG0=$(gum style --margin "1 2" --padding "1 5" --width 80 --border double --border-foreground 208 "I")
# MSG1=$(gum style --margin "1 2" --padding "1 4" --width 80 --border double --border-foreground 57 "LOVE")
#
#
# MSG2=$(gum style --margin "1 2" --width 80 --padding "1 8" --border double --border-foreground 255 "Bubble")
#
#
# MSG3=$(gum style --margin "1 2" --width 80 --padding "1 5" --border double --border-foreground 240 "Gum")

# gum join "$MSG0"; sleep 1 ; gum join "$MSG1"
# sleep 1
# gum join "$MSG2" "$MSG3"

# sleep 2
# exit
# Export functions so they're available to subshells
export -f extract_tasks
export -f preview_task

# Main menu
while true; do
    action=$(echo -e "Select Playbook\nSelect Host(s)\nSelect Tags\nSelect Task\nPreview Command\nExecute Playbook\nReset\nExit" | \
          gum filter)
        # fzf --header="Ansible Menu" \
        #     --layout="reverse" \
        #     --prompt="Action > ")

    case "$action" in
        "Select Playbook")
            select_playbook
            ;;
        "Preview Command")
            preview_command
            gum confirm "Do you like what you see???" || reset_vars
            ;;
        "Execute Playbook")
            execute_playbook
            ;;
        "Select Tags")
            select_tags
            ;;
        "Select Host(s)")
            select_hosts
            ;;
        "Select Task")
            select_task
            ;;
        "Reset")
            reset_vars
            ;;
        "Exit")
            exit 0
            ;;
    esac

done
