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

wipe() {
tput -S <<!
clear
cup 1
!
}

wipe="false"

# and so it begins...
wipe && say "hello!\n" $GREEN && sleep 0.5

function prompt_for_userid() {
    read -p "Please enter the user id: " userid
    echo $userid
}

userid=$(prompt_for_userid)
echo "You entered: $userid"

group_name="${userid}"
group_id=1000

if getent group "$group_name" > /dev/null; then
  echo "Group '$group_name' already exists."
else
  groupadd -g "$group_id" "$group_name"
  usermod -a -G "$group_id" "$userid"
  echo "Group '$group_name' created and user '$userid' added to it."
fi

distro=""

# Determine distribution
if [ -f /etc/lsb-release ]; then
	. /etc/lsb-release
	distro=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
	distro="debian"
elif [ -f /etc/redhat-release ]; then
	distro="redhat"
fi


# and so it begins...
wipe && say "hello!\n" $GREEN && sleep 0.5

say "-----------------------------------------------" $BLUE
say "installing ssh, fd, ruby along with" $BLUE
say "gcc, g++, make, and other essential build tools" $BLUE
say "ssh will also be enabled and started." $BLUE
say "-----------------------------------------------\n" $BLUE

case $distro in
	Arch|Manjaro)
		pacman -Syu --noconfirm --downloadonly --quiet
    pacman -S --noconfirm openssh base-devel rsync openssh python-pip python-setuptools rustup fd rubygems yadm jack2 jack2-dbus pulseaudio pulseaudio-jack pulseaudio-alsa net-tools htop gum most ranger nodejs npm --overwrite '*'
		systemctl enable sshd
		systemctl start sshd
		;;
	Debian|Raspbian|MX)
		apt-get update --quiet
		apt-get install -y openssh-server build-essential fd-find ruby-rubygems ruby-bundler ruby-dev
		systemctl enable ssh
		systemctl start ssh
		;;
	*)
		echo "Unsupported distribution."
		exit 1
esac

sleep 0.5

if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
say "\n-----------------------------------------------" $BLUE

if [[ ! -f "/home/${userid}/.ssh/id_ed25519.pub" ]]; then
  # read -p "Enter the username and hostname of the remote host (e.g. user@example.com): " REMOTE_HOST
  REMOTE_HOST="${userid}@bender.syncopated.net"
  cd /home/$userid && rsync -avP --delete $REMOTE_HOST:~/.ssh .
  chown -R $userid:$userid /home/$userid/
  scp $REMOTE_HOST:~/.gitconfig .
else
  say "ssh keys present"
fi

say "-----------------------------------------------\n" $BLUE

if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
say "\n-----------------------------------------------" $BLUE
say "enable and start firewall service" $BLUE
say "set defaults to deny inbound and allow outbound" $BLUE
say "add rule to allow ssh traffic" $BLUE
say "-----------------------------------------------\n" $BLUE

# Set firewall rules
case $distro in
	Debian|Raspbian|MX)
		apt-get install -y ufw
		ufw default deny incoming
		ufw default allow outgoing
		ufw allow ssh
		ufw enable
		;;
	Arch|Manjaro)
		pacman -S --noconfirm firewalld
		systemctl enable firewalld
		systemctl start firewalld
		firewall-cmd --zone=public --add-service=ssh --permanent
		firewall-cmd --reload
		;;
	*)
		echo "Unsupported distribution: $distro"
		exit 1
		;;
esac

sleep 0.5

if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
say "\n-----------------------------------------------" $BLUE
say "check for ansible installations..." $BLUE
say "if installed with a system package," $BLUE
say "remove the system package and install with pip" $BLUE
say "as of date, pip will install ansible 2.14.5" $BLUE
say "-----------------------------------------------\n" $BLUE

case $distro in
	Debian|Raspbian|MX)
		if [ -x $(apt list --installed | grep ansible) ]; then
			apt-get remove -y ansible --quiet
		fi
		;;
	Arch|Manjaro)
		if [ -x $(pacman -Q | grep ansible) ]; then
      echo "ansible package not found"
    else
      echo "ansible package found...removing"
			pacman -Rdd ansible --noconfirm
		fi
		;;
	*)
		echo "Unsupported distribution: $distro"
		exit 1
		;;
esac

if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
say "\n-----------------------------------------------" $BLUE
say "installing pip" $BLUE && sleep 0.5
say "-----------------------------------------------\n" $BLUE

case $distro in
	Debian|Raspbian|MX)
		apt-get update --quiet
		apt-get install -y python3-pip && \
    pip install ansible
		;;
	Arch|Manjaro)
    if [ -x $(pacman -Q | grep python-pip) ]; then
      echo "pip not installed"
  		pacman -S --noconfirm python-pip
    else
      echo "pip installed"
    fi
		;;
	*)
		echo "Unsupported distribution: $distro"
		exit 1
		;;
esac

say "\n-----------------------------------------------" $BLUE
say "installing ansible via pip" $BLUE
say "-----------------------------------------------\n" $BLUE

case $distro in
	Debian|Raspbian|MX)
    pip install ansible
		;;
	Arch|Manjaro)
    pip install ansible --break-system-packages
		;;
	*)
		echo "Unsupported distribution: $distro"
		exit 1
		;;
esac

if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi

say "\n-----------------------------------------------" $BLUE
say "installing additional support packages" $BLUE
say "-----------------------------------------------\n" $BLUE


BOOTSTRAP_PKGS=(
  'aria2'
  'bat'
  'bc'
  'cargo'
  'ccache'
  'cmake'
  'dialog'
  'git'
  'git-lfs'
  'htop'
  'lnav'
  'neovim'
  'net-tools'
  'unzip'
  'wget'
  'zsh'
)

case $distro in
	Debian|Raspbian|MX)
		apt-get update --quiet
		apt-get install -y "${BOOTSTRAP_PKGS[@]}"
		;;
	Arch|Manjaro)
		pacman -S --noconfirm --needed "${BOOTSTRAP_PKGS[@]}"
		;;
	*)
		echo "Unsupported distribution: $distro"
		exit 1
		;;
esac

wipe && sleep 1

say "\n-----------------------------------------------" $BLUE
say "bootstrap complete. run ansible playbook...." $BLUE
say "-----------------------------------------------\n" $BLUE

sleep 10
