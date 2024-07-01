#!/bin/bash
set -e

# --- Error Handling ---
ctrl_c() {
  echo "** End."
  sleep 1
}
trap ctrl_c INT SIGINT SIGTERM ERR EXIT

# --- Colors ---
ALL_OFF="\e[1;0m"
BBOLD="\e[1;1m"
BLUE="${BBOLD}\e[1;34m"
GREEN="${BBOLD}\e[1;32m"
RED="${BBOLD}\e[1;31m"
YELLOW="${BBOLD}\e[1;33m"

# --- Display Function ---
say() {
  echo -e "${2}${1}${ALL_OFF}"
}

# --- User Input ---
prompt_for_userid() {
  read -p "Please enter the user id: " USERNAME
  echo "$USERNAME"
}

# --- Sudoers Setup (Idempotent) ---
setup_sudoers() {
  echo "Setting up sudoers for ${USER}..."

  # Check if sudoers entry already exists
  if grep -q "${USER} ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers.d/99-${USER}; then
    echo "Sudoers entry already exists."
  else
    echo "${USER} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/99-${USER}"
  fi

  sudo visudo -cf "/etc/sudoers.d/99-${USER}"

  if [ $? -eq 0 ]; then
    echo "Sudoers file is valid"
  else
    echo "Sudoers file is invalid"
    return 1
  fi

  case $DISTRO in
    Arch|ArchLabs|cachyos|EndeavourOS)
      cat << EOF | sudo tee /etc/polkit-1/rules.d/49-nopasswd_global.rules
polkit.addRule(function(action, subject) {
  if (subject.isInGroup("${USER}")) {
    return polkit.Result.YES;
  }
});
EOF
      sudo chmod 0644 /etc/polkit-1/rules.d/49-nopasswd_global.rules
      ;;
    Debian|Raspbian|MX|Pop)
      cat << EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/admin_group.pkla
[set admin_group privs]
Identity=unix-group:sudo
Action=*
ResultActive=yes
EOF
      ;;
    *)
      echo "Unsupported distribution for polkit setup."
      return 1
  esac

  echo "Sudoers and polkit setup completed."
}

# --- Git Configuration (Idempotent) ---
setup_gitconfig() {
  echo "Setting up .gitconfig..."

  # Check if git config already exists
  if git config --global --get user.name && git config --global --get user.email; then
    echo "Git configuration already exists."
  else
    git_name=$(gum input --value "b08x" --prompt "Enter your Git username: ")
    git_email=$(gum input --value "rwpannick@gmail.com" --prompt "Enter your Git email: ")

    git config --global user.name "${git_name}"
    git config --global user.email "${git_email}"
  fi

  echo "Git configuration has been set up."
  echo "Name: $(git config --global user.name)"
  echo "Email: $(git config --global user.email)"
}

# --- SSH Key Setup (Idempotent) ---
setup_ssh_keys() {
  if [ -f "${HOME}/.ssh/id_ed25519" ] && [ -f "${HOME}/.ssh/id_ed25519.pub" ]; then
    echo "SSH keys already exist."
    return 0
  fi

  echo "SSH keys not found. Attempting to transfer from another host."
  REMOTE_HOST=$(gum input --placeholder "hostname.domain.net" --prompt "Enter the hostname where SSH keys are stored: ")
  ssh_folder=$(gum input --value "${HOME}/.ssh" --prompt "Enter the folder name for SSH keys: ")

  # Copy SSH keys
  if rsync -avP --delete "${REMOTE_HOST}:~/.ssh/" "${HOME}/.ssh/"; then
    # Set proper permissions for SSH keys
    chmod 700 "${HOME}/.ssh"
    chmod 600 "${HOME}/.ssh"/*
    echo "SSH keys successfully transferred and set up."
    return 0
  else
    echo "Failed to transfer SSH keys."
    return 1
  fi
}
# --- Package Installation (Idempotent) ---
install_packages() {
  echo "Installing essential packages..." $GREEN

  DISTRO=$(lsb_release -si)

  case $DISTRO in
    Arch|ArchLabs|cachyos|EndeavourOS)
      # Check if packages are already installed
      if ! pacman -Qi openssh base-devel rsync openssh python-pip \
      firewalld python-setuptools rustup fd rubygems yadm jack2 jack2-dbus \
      pulseaudio pulseaudio-jack pulseaudio-alsa net-tools htop gum most ranger \
      nodejs npm ansible &> /dev/null; then
        sudo pacman -Syu --noconfirm --downloadonly --quiet
        sudo pacman -S --noconfirm openssh base-devel rsync openssh python-pip \
        firewalld python-setuptools rustup fd rubygems yadm jack2 jack2-dbus \
        pulseaudio pulseaudio-jack pulseaudio-alsa net-tools htop gum most ranger \
        nodejs npm ansible --overwrite '*'
      fi
      ;;
    Fedora|Fedora)
      # Check if packages are already installed
      if ! dnf list installed gum ansible &> /dev/null; then
        echo '[charm]
        name=Charm
        baseurl=https://repo.charm.sh/yum/
        enabled=1
        gpgcheck=1
        gpgkey=https://repo.charm.sh/yum/gpg.key' | tee /etc/yum.repos.d/charm.repo
        sudo dnf -y install gum ansible
      fi
      ;;
    Debian|Raspbian|MX|Pop)
      # Check if packages are already installed
      if ! dpkg -l openssh-server build-essential fd-find ruby-rubygems ruby-bundler ruby-dev gum ansible &> /dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt-get update --quiet && \
        sudo apt-get install -y openssh-server build-essential fd-find ruby-rubygems ruby-bundler ruby-dev gum ansible
      fi
      ;;
    *)
      echo "Unsupported distribution."
      exit 1
  esac
}

# --- Repository Cloning (Idempotent) ---
clone_repository() {
  echo "Cloning SyncopatedOS repository..." $GREEN

  # Check if repository is already cloned
  if [ -d "${DOTFILES_DIR}" ]; then
    echo "Repository already cloned."
  else
    say "Select branch" $BLUE
    branch=$(gum choose "main" "development" "feature/popos")
    git clone --recursive -b "${branch}" git@github.com:b08x/SyncopatedOS "${DOTFILES_DIR}"
  fi
}

# --- Main Script ---
# Set up variables
USER_HOME="${HOME}"
CONFIG_DIR="${USER_HOME}/.config"
DOTFILES_DIR="${CONFIG_DIR}/dotfiles"
ANSIBLE_HOME="${DOTFILES_DIR}"

install_packages
setup_ssh_keys
setup_gitconfig

# --- Sudoers Setup (Optional) ---
if gum confirm "Do you want to set up sudoers for passwordless sudo?" --default="Yes"; then
  setup_sudoers
  if [ $? -ne 0 ]; then
    echo "Sudoers setup failed. Continuing with the rest of the script."
  fi
else
  echo "Skipping sudoers setup."
fi

clone_repository

# --- Environment Variables ---
say "Enter additional environment variables (press Enter with empty input to finish):" $BLUE
declare -A env_vars
while true; do
  var_name=$(gum input --prompt "Variable name (or Enter to finish): ")
  [ -z "$var_name" ] && break
  var_value=$(gum input --prompt "Value for $var_name: ")
  env_vars["$var_name"]="$var_value"
done

# --- Ansible Playbook Execution ---
say "Running Ansible playbook..." $GREEN
env_command="env ANSIBLE_HOME=${ANSIBLE_HOME}"
for var in "${!env_vars[@]}"; do
  env_command+=" $var=${env_vars[$var]}"
done
eval "${env_command} ansible-playbook -i ${ANSIBLE_HOME}/inventory setup.yml"
