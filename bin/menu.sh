#!/bin/bash

# Function to display tasks in a new terminal window
view_tasks() {
  local role="$1"
  local task_dir="roles/$role/tasks"
  if [[ -d "$task_dir" ]]; then
    # Get the list of task files
    task_list=$(find "$task_dir" -type f -printf "%f\n")

    # Display tasks using FZF
    selected_task=$(echo "$task_list" | fzf --height=40% --reverse)

    if [[ -n "$selected_task" ]]; then
      # Construct the full path to the selected task file
      selected_file="$task_dir/$selected_task"

      # Open the task file in your preferred editor or viewer
      terminator -e "cat '$selected_file' | less; bash"
    else
      echo "No task selected."
    fi
  else
    echo "Error: Role directory not found: $role"
  fi
}

# Get the list of roles from the 'roles' directory
role_list=$(find roles/ -maxdepth 1 -type d -printf "%P\n" | sed '1d')

# Use FZF to display the role menu
selected_role=$(echo "$role_list" | fzf --height=40% --reverse)

# Check if a role was selected
if [[ -n "$selected_role" ]]; then
  view_tasks "$selected_role"
else
  echo "No role selected."
fi
