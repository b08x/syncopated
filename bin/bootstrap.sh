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
wipe && say "hello!\n" $GREEN && sleep 0.5

say "-----------------------------------------------" $BLUE
say "installing ssh, fd, ruby along with" $BLUE
say "gcc, g++, make, and other essential build tools" $BLUE
say "ssh will also be enabled and started." $BLUE
say "-----------------------------------------------\n" $BLUE

BOOTSTRAP_PKGS=(
  'ansible'
  'aria2'
  'base-devel' 
  'bat'
  'bc'
  'cargo'
  'ccache'
  'cmake'
  'dialog'
  'fd' 
  'git'
  'git-lfs'
  'gum' 
  'htop'
  # 'jack2' 
  # 'jack2-dbus' 
  'lnav'
  'most' 
  'neovim'
  'net-tools'
  'nodejs' 
  'npm'
  'openssh' 
  # 'pulseaudio' 
  # 'pulseaudio-alsa' 
  # 'pulseaudio-jack' 
  'python-pip' 
  'python-setuptools' 
  'ranger' 
  'rsync' 
  'rubygems' 
  'rustup' 
  'unzip'
  'wget'
  'yadm' 
  'zsh'
)


pacman -Syu --noconfirm --downloadonly --quiet

pacman -S --noconfirm --needed "${BOOTSTRAP_PKGS[@]}" --overwrite '*'

systemctl enable sshd
systemctl start sshd

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Hello, there! Welcome to $(gum style --foreground 212 'Gum')."


USERNAME=$(prompt_for_userid)
echo "You entered: $USERNAME"

USERGROUP="${USERNAME}"
USERGROUPID=1000

if getent group "$USERGROUP" > /dev/null; then
  echo "Group '$USERGROUP' already exists."
else
  groupadd -g "$USERGROUPID" "$USERGROUP"
  usermod -a -G "$USERGROUPID" "$USERNAME"
  echo "Group '$USERGROUP' created and user '$USERNAME' added to it."
fi

if [[ ! -f "/home/${USERNAME}/.ssh/id_ed25519.pub" ]]; then

	KEYSERVER=$(gum input --placeholder "enter KEYSERVER hostname")

	while true; do
		gum confirm "is ${KEYSERVER} correct?" && fetch_keys
		if [ $? -eq 0 ]; then
			break # Exit the loop when affirmative response is received
		else
			KEYSERVER=$(gum input --placeholder "enter KEYSERVER hostname")
		fi
	done

fi

# install ruby gems
echo "gem: --user-install --no-document" | tee /etc/gemrc
echo "gem: --no-user-install" | tee /root/.gemrc
echo "gem: --user-install" | tee /home/$USERNAME/.gemrc && chown $USERNAME:$USERGROUP /home/$USERNAME/.gemrc

INSTALLED_GEMS=$(gem list | awk '{ print $1 }')

GEMS=(
  'activesupport'
  'awesome_print'
  'bcrypt_pbkdf'
  'childprocess'
  'ed25519'
  'eventmachine'
  'ffi'
  'fractional'
  'geo_coord'
  'highline'
  'i3ipc'
  'i18n'
  'kramdown'
  'logging'
  'minitest'
  'mocha'
  'multi_json'
  'net-ssh'
  'parallel'
  'pastel'
  'pry'
  'pry-doc'
  'pycall'
  'rake'
  'rdoc'
  'rexml'
  'rouge'
  'sync'
  'sys-proctable'
  'tty-box'
  'tty-command'
  'tty-cursor'
  'tty-prompt'
  'tty-screen'
  'tty-tree'
)


# https://stackoverflow.com/a/42399479
mapfile -t DIFF < \
    <(comm -23 \
        <(IFS=$'\n'; echo "${GEMS[*]}" | sort) \
        <(IFS=$'\n'; echo "${INSTALLED_GEMS[*]}" | sort) \
    )

for gem in "${DIFF[@]}"; do
  gem install "$gem" || continue
done

sleep 0.5

say "-----------------------------------------------\n" $BLUE

if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
say "\n-----------------------------------------------" $BLUE
say "enable and start firewall service" $BLUE
say "set defaults to deny inbound and allow outbound" $BLUE
say "add rule to allow ssh traffic" $BLUE
say "-----------------------------------------------\n" $BLUE

pacman -S --noconfirm firewalld

systemctl enable firewalld && systemctl start firewalld

firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --reload

wipe && sleep 1

echo -e "Finished, $(gum style --foreground 212 "...")."

say "\n-----------------------------------------------" $BLUE
say "bootstrap complete. run ansible playbook...." $BLUE
say "-----------------------------------------------\n" $BLUE

sleep 10
