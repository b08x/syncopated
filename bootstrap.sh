#!/bin/bash
set -e

# set a trap to exit with CTRL+C
ctrl_c() {
        echo "** End."
        sleep 1
}

trap ctrl_c INT SIGINT SIGTERM ERR EXIT

# declare colors!
declare -rx ALL_OFF="\e[1;0m"
declare -rx BBOLD="\e[1;1m"
declare -rx BLUE="${BOLD}\e[1;34m"
declare -rx GREEN="${BOLD}\e[1;32m"
declare -rx RED="${BOLD}\e[1;31m"
declare -rx YELLOW="${BOLD}\e[1;33m"

# cli display functions
say () {
  local statement=$1
  local color=$2

  echo -e "${color}${statement}${ALL_OFF}"
}

prompt_for_userid() {
    read -p "Please enter the user id: " USERNAME
    echo $USERNAME
}

setup_sudoers() {
    echo "Setting up sudoers for ${USER}..."

    echo "${USER} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/99-${USER}"

    sudo visudo -cf "/etc/sudoers.d/99-${USER}"

    if [ $? -eq 0 ]; then
        echo "Sudoers file is valid"
    else
        echo "Sudoers file is invalid"
        return 1
    fi

    # Determine the distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo "Unable to determine distribution. Skipping polkit setup."
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

# Function to set up .gitconfig
setup_gitconfig() {
    echo "Setting up .gitconfig..."

    git_name=$(gum input --prompt "Enter your Git username: ")
    git_email=$(gum input --prompt "Enter your Git email: ")

    git config --global user.name "${git_name}"
    git config --global user.email "${git_email}"

    echo "Git configuration has been set up."
    echo "Name: ${git_name}"
    echo "Email: ${git_email}"
}

# Function to set up SSH keys
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

wipe() {
tput -S <<!
clear
cup 1
!
}

wipe="false"

# and so it begins...

# Set up variables
USER_HOME="${HOME}"
CONFIG_DIR="${USER_HOME}/.config"
DOTFILES_DIR="${CONFIG_DIR}/dotfiles"
ANSIBLE_HOME="${DOTFILES_DIR}"

wipe && say "hello!\n" $GREEN && sleep 0.5

say "-----------------------------------------------" $BLUE
say "installing ssh, gum, ruby along with" $BLUE
say "gcc, g++, make, and other essential build tools" $BLUE
say "-----------------------------------------------\n" $BLUE

DISTRO=$(lsb_release -si)

case $DISTRO in
	Arch|ArchLabs|cachyos|EndeavourOS)
		sudo pacman -Syu --noconfirm --downloadonly --quiet
    sudo pacman -S --noconfirm openssh base-devel rsync openssh python-pip \
    firewalld python-setuptools rustup fd rubygems yadm jack2 jack2-dbus \
    pulseaudio pulseaudio-jack pulseaudio-alsa net-tools htop gum most ranger \
    nodejs npm ansible --overwrite '*'
		;;
	Fedora|Fedora)
		echo '[charm]
		name=Charm
		baseurl=https://repo.charm.sh/yum/
		enabled=1
		gpgcheck=1
		gpgkey=https://repo.charm.sh/yum/gpg.key' | tee /etc/yum.repos.d/charm.repo
		sudo dnf -y install gum ansible
		;;
	Debian|Raspbian|MX|Pop)
		sudo mkdir -p /etc/apt/keyrings
		curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
		echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
		sudo apt-get update --quiet && \
		sudo apt-get install -y openssh-server build-essential fd-find ruby-rubygems ruby-bundler ruby-dev gum ansible
		;;
	*)
		echo "Unsupported distribution."
		exit 1
esac


gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Hello, there! Welcome to $(gum style --foreground 212 'this')."

setup_ssh_keys
setup_gitconfig

# Prompt for sudoers setup
if gum confirm "Do you want to set up sudoers for passwordless sudo?" --default="Yes"; then
    setup_sudoers
    if [ $? -ne 0 ]; then
        echo "Sudoers setup failed. Continuing with the rest of the script."
    fi
else
    echo "Skipping sudoers setup."
fi

# Prompt for branch selection
branch=$(gum choose "main" "development" "feature/popos" --prompt "Select the branch to clone:")

# Clone the repository with the selected branch
git clone --recursive -b "${branch}" git@github.com:b08x/SyncopatedOS "${DOTFILES_DIR}"

# Prompt for additional environment variables
echo "Enter additional environment variables (press Enter with empty input to finish):"
declare -A env_vars
while true; do
    var_name=$(gum input --prompt "Variable name (or Enter to finish): ")
    [ -z "$var_name" ] && break
    var_value=$(gum input --prompt "Value for $var_name: ")
    env_vars["$var_name"]="$var_value"
done

# Construct the env command with all variables
env_command="env ANSIBLE_HOME=${ANSIBLE_HOME}"
for var in "${!env_vars[@]}"; do
    env_command+=" $var=${env_vars[$var]}"
done

echo "test complete!"

# Run the initial setup playbook with environment variables
eval "${env_command} ansible-playbook -i ${ANSIBLE_HOME}/inventory setup.yml"
