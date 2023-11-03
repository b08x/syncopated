#!/bin/bash
set -e

export PATH="/usr/local/bin:${HOME}/.local/share/gem/ruby/3.0.0/bin:${PATH}"

PKGS=(
  'alacritty'
  'aria2'
  'autorandr'
  'barrier'
  'bat'
  'bc'
  'bind'
  'eza'
  'fd'
  'fzf'
  'github-cli'
  'gitui'
  'graphicsmagick'
  'gum'
  'help2man'
  'htop'
  'i3status-rust'
  'imlib2'
  'inxi'
  'keepassxc'
  'kitty'
  'libxcrypt-compat'
  'libxml2'
  'lnav'
  'most'
  'ncurses'
  'neovim-symlinks'
  'net-tools'
  'nodejs'
  'npm'
  'openssl'
  'openssl-1.1'
  'ranger'
  'sxhkd'
  'tilda'
  'ueberzug'
  'zoxide'
  'zsh-autosuggestions'
  'zsh-syntax-highlighting'
)

function mkcd() {
  mkdir -p "$1" && cd "$1";
}

# set a trap to exit with CTRL+C
ctrl_c() {
        echo "** End."
        sleep 1
}

trap ctrl_c INT SIGINT SIGTERM ERR EXIT

# Check if the user is root
if [[ $(id -u) -eq 0 ]]; then
   echo "It is advised to not run this as root. Run this as the user you wish to configure"
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

# clean cache
sudo pacman -Scc --noconfirm > /dev/null
sudo pacman -Syu rsync openssh python-pip python-setuptools rustup rubygems yadm jack2 jack2-dbus pulseaudio pulseaudio-jack pulseaudio-alsa net-tools htop gum most ranger nodejs npm --overwrite '*'

say "-----------------------------------------------" $BLUE
say "enabling ssh" $BLUE
say "-----------------------------------------------\n" $BLUE

sudo systemctl enable sshd
sudo systemctl start sshd

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

# if [[ $wipe == 'true' ]]; then wipe && sleep 1; fi
# say "\n-----------------------------------------------" $BLUE
# say "installing packages" $BLUE
# say "-----------------------------------------------\n" $BLUE

# ansible-pull -U git@github.com:SyncopatedLinux/cfgmgmt.git \
#              -C development \
#              -i inventory \
#              -e "newInstall=true"

# rustup default stable

# install packages
# paru -S --noconfirm --needed --cleanafter --useask --upgrademenu "${PKGS[@]}"
#
# if [ $? = 0 ]; then
#   cd $HOME && yadm clone git@github.com:b08x/dots.git -f
# fi

# sudo echo "gem: --user-install" > /etc/gemrc
# echo "gem: --user-install" > $HOME/.gemrc

# gem install neovim solargraph yard

# # install vim plug
# sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
# https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
#
# # install vim plugins
# if [ -x "$(command -v nvim)" ]; then
#   echo "Bootstraping NeoVim"
#   /usr/bin/nvim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+CocInstall coc-solargraph' '+qall'
# fi
#
# jack_control eps driver alsa
# jack_control dps monitor true
# jack_control dps midi-driver seq
# jack_control eps realtime-priority 80
