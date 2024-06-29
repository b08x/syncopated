#!/bin/bash
set -e

# set a trap to exit with CTRL+C
ctrl_c() {
        echo "** End."
        sleep 1
}

trap ctrl_c INT SIGINT SIGTERM ERR EXIT

# Check if the user is root
if [[ $(id -u) -eq 0 ]]; then
   echo "Run this as user"
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
wipe && say "hello!\n" $GREEN && sleep 1

pacman -Syu --noconfirm --downloadonly --quiet

export PATH="/usr/local/bin:$PATH"

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

wipe && say "setting default toolchain!\n" $GREEN && sleep 1

su - $USERNAME -c "rustup default stable"

echo -e "Finished, $(gum style --foreground 212 "...")."

say "\n-----------------------------------------------" $BLUE
say "bootstrap complete. reboot & run ansible playbook...." $BLUE
say "-----------------------------------------------\n" $BLUE

sleep 4
