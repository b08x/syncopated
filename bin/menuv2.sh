#!/bin/bash

# Function to display tasks in a new tmux pane
view_tasks() {
  local role="$1"
  local task_dir="roles/$role/tasks"
  if [[ -d "$task_dir" ]]; then
    # Get the list of task files
    task_list=$(find "$task_dir" -type f -printf "%f\n")

    # Display tasks using fzf-tmux in a new pane
    selected_task=$(echo "$task_list" | fzf-tmux -p --height=40% --reverse)

    if [[ -n "$selected_task" ]]; then
      # Construct the full path to the selected task file
      selected_file="$task_dir/$selected_task"

      # Open the task file in a new pane with your preferred editor/viewer
      tmux split-window -h -c "$task_dir"  "cat '$selected_file' | less"
    else
      echo "No task selected."
    fi
  else
    echo "Error: Role directory not found: $role"
  fi
}

# Get the list of roles from the 'roles' directory
role_list=$(find roles/ -maxdepth 1 -type d -printf "%P\n" | sed '1d')

# Use fzf-tmux to display the role menu in a new pane
selected_role=$(echo "$role_list" | fzf-tmux -p --height=40% --reverse)

# Check if a role was selected
if [[ -n "$selected_role" ]]; then
  view_tasks "$selected_role"
else
  echo "No role selected."
fi
