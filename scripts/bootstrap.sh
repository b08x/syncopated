#!/bin/bash
set -e

# set a trap to exit with CTRL+C
ctrl_c() {
        echo "** End."
        sleep 1
}

trap ctrl_c INT SIGINT SIGTERM ERR EXIT

# Check if the user is root
if [[ $(id -u) -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

# Ensure the script is run as a non-root user
if [ "$(id -u)" -eq 0 ]; then
    echo "This script must be run as a non-root user" >&2
    exit 1
fi

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

fetch_keys() {
  # set remote host
	local REMOTE_HOST="${USERNAME}@${KEYSERVER}"
	# sync ssh keys
	cd /home/$USERNAME && rsync -avP --delete $REMOTE_HOST:~/.ssh .
	# pull gitconfig
	rsync -avP --chown=$USERNAME:$USERNAME $REMOTE_HOST:~/.gitconfig .
	# ensure perms
	chown -R $USERNAME:$USERGROUP /home/$USERNAME/
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
		pacman -Syu --noconfirm --downloadonly --quiet
    pacman -S --noconfirm openssh base-devel rsync openssh python-pip \
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
		dnf -y install gum ansible
		;;
	Debian|Raspbian|MX|Pop)
		mkdir -p /etc/apt/keyrings
		curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
		echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list
		apt-get update --quiet
		apt-get install -y openssh-server build-essential fd-find ruby-rubygems ruby-bundler ruby-dev gum ansible
		;;
	*)
		echo "Unsupported distribution."
		exit 1
esac


gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Hello, there! Welcome to $(gum style --foreground 212 'Gum')."


# USERNAME=$(prompt_for_userid)
# echo "You entered: $USERNAME"
#
# USERGROUP="${USERNAME}"
# USERGROUPID=1000
#
# if getent group "$USERGROUP" > /dev/null; then
#   echo "Group '$USERGROUP' already exists."
# else
#   groupadd -g "$USERGROUPID" "$USERGROUP"
#   usermod -a -G "$USERGROUPID" "$USERNAME"
#   echo "Group '$USERGROUP' created and user '$USERNAME' added to it."
# fi
#
# if [[ ! -f "/home/${USERNAME}/.ssh/id_ed25519.pub" ]]; then
#
# 	KEYSERVER=$(gum input --placeholder "enter KEYSERVER hostname")
#
# 	while true; do
# 		gum confirm "is ${KEYSERVER} correct?" && fetch_keys
# 		if [ $? -eq 0 ]; then
# 			break # Exit the loop when affirmative response is received
# 		else
# 			KEYSERVER=$(gum input --placeholder "enter KEYSERVER hostname")
# 		fi
# 	done
#
# fi

# install ruby gems
# echo "gem: --user-install --no-document" | tee /etc/gemrc
# echo "gem: --no-user-install" | tee /root/.gemrc
# echo "gem: --user-install" | tee /home/$USERNAME/.gemrc && chown $USERNAME:$USERGROUP /home/$USERNAME/.gemrc
#
# INSTALLED_GEMS=$(gem list | awk '{ print $1 }')
#
# GEMS=(
#   'activesupport'
#   'awesome_print'
#   'bcrypt_pbkdf'
#   'childprocess'
#   'ed25519'
#   'eventmachine'
#   'ffi'
#   'fractional'
#   'geo_coord'
#   'highline'
#   'i3ipc'
#   'i18n'
#   'kramdown'
#   'logging'
#   'minitest'
#   'mocha'
#   'multi_json'
#   'net-ssh'
#   'parallel'
#   'pastel'
#   'pry'
#   'pry-doc'
#   'pycall'
#   'rake'
#   'rdoc'
#   'rexml'
#   'rouge'
#   'sync'
#   'sys-proctable'
#   'tty-box'
#   'tty-command'
#   'tty-cursor'
#   'tty-prompt'
#   'tty-screen'
#   'tty-tree'
# )
#
#
# # https://stackoverflow.com/a/42399479
# mapfile -t DIFF < \
#     <(comm -23 \
#         <(IFS=$'\n'; echo "${GEMS[*]}" | sort) \
#         <(IFS=$'\n'; echo "${INSTALLED_GEMS[*]}" | sort) \
#     )
#
# for gem in "${DIFF[@]}"; do
#   gem install "$gem" || continue
# done
#
# sleep 0.5
#
# say "-----------------------------------------------\n" $BLUE
#
# if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
# say "\n-----------------------------------------------" $BLUE
# say "enable and start firewall service" $BLUE
# say "set defaults to deny inbound and allow outbound" $BLUE
# say "add rule to allow ssh traffic" $BLUE
# say "-----------------------------------------------\n" $BLUE
#
# # Set firewall rules
# case $DISTRO in
# 	Debian|Raspbian|MX)
# 		apt-get install -y ufw
# 		ufw default deny incoming
# 		ufw default allow outgoing
# 		ufw allow ssh
# 		ufw enable
# 		;;
# 	Arch|ArchLabs|Manjaro)
# 		pacman -S --noconfirm firewalld
# 		systemctl enable firewalld
# 		systemctl start firewalld
# 		firewall-cmd --zone=public --add-service=ssh --permanent
# 		firewall-cmd --reload
# 		;;
# 	*)
# 		echo "Unsupported distribution: $DISTRO"
# 		exit 1
# 		;;
# esac
#
# wipe && sleep 1
#
# if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
# say "\n-----------------------------------------------" $BLUE
# say "check for ansible installations..." $BLUE
# say "if installed with a system package," $BLUE
# say "remove the system package and install with pip" $BLUE
# say "as of date, pip will install ansible 2.14.5" $BLUE
# say "-----------------------------------------------\n" $BLUE
#
# case $DISTRO in
# 	Debian|Raspbian|MX)
# 		if [ -x $(apt list --installed | grep ansible) ]; then
# 			apt-get remove -y ansible --quiet
# 		fi
# 		;;
# 	Arch|ArchLabs|Manjaro)
# 		if [ -x $(pacman -Q | grep ansible) ]; then
#       echo "ansible package not found"
#     else
#       echo "ansible package found...removing"
# 			pacman -Rdd ansible --noconfirm
# 		fi
# 		;;
# 	*)
# 		echo "Unsupported distribution: $DISTRO"
# 		exit 1
# 		;;
# esac
#
# if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
# say "\n-----------------------------------------------" $BLUE
# say "installing pip" $BLUE && sleep 0.5
# say "-----------------------------------------------\n" $BLUE
#
# case $DISTRO in
# 	Debian|Raspbian|MX)
# 		apt-get update --quiet
# 		apt-get install -y python3-pip && \
#     pip install ansible
# 		;;
# 	Arch|ArchLabs|Manjaro)
#     if [[ -x $(pacman -Q | grep python-pip) ]]; then
#       echo "pip not installed"
#   		pacman -S --noconfirm python-pip && \
#       pip install ansible --break-system-packages
#     else
#       echo "pip installed"
#     fi
# 		;;
# 	*)
# 		echo "Unsupported distribution: $DISTRO"
# 		exit 1
# 		;;
# esac
#
# echo -e "Finished, $(gum style --foreground 212 "...")."
#
# say "\n-----------------------------------------------" $BLUE
# say "bootstrap complete. run ansible playbook...." $BLUE
# say "-----------------------------------------------\n" $BLUE
#
# sleep 10
