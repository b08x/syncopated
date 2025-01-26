#!/bin/bash

########################################################################
#                                                                      #
#  Here you can edit the script runned                                 #
#  each time daemon order this session to be loaded                    #
#  WARNING: You can be here in a switch situation,                     #
#           some clients may be still alive                            #
#           if they are NSM compatible and capable of switch,          #
#           or if they are not NSM compatible at all                   #
#           but launched with NSM protocol and not via proxy           #
#                                                                      #
#  You have access the following environment variables                 #
#  RAY_SESSION_PATH : Folder of the current session                    #
#  RAY_SCRIPTS_DIR  : Folder containing this script                    #
#     ray-scripts folder can be directly in current session            #
#     or in a parent folder.                                           #
#  RAY_PARENT_SCRIPT_DIR : Folder containing the scripts that would    #
#     be runned if RAY_SCRIPTS_DIR would not exists                    #
#  RAY_SWITCHING_SESSION: 'true' or 'false'                            #
#     'true' if session is switching from another session              #
#     and probably some clients are still alive.                       #
#                                                                      #
#  To get any other session informations, refers to ray_control help   #
#     typing: ray_control --help                                       #
#                                                                      #
########################################################################

# script here some actions to run before loading the session.
bash stop-gvfs.sh

bash disconnect_pulse.sh

sudo cpupower frequency-set --governor performance

if ! pgrep -x "reaper" > /dev/null
then
  cd $HOME/Sessions/ #TODO: set to /home/x/Projects

  project=$(zenity --width 800 --height 600 --list --title="reaper projects" \
    --text="select reaper project to open" --column="project" $(fd -a -e .rpp))

  if [ -z $project ];then
    i3-msg "exec --no-startup-id reaper -nosplash";sleep 2
  else
    i3-msg "exec --no-startup-id reaper -nosplash $project";sleep 2
  fi
else
  systemd-cat -t "load_session" echo "reaper is currently open"
fi


# set this var true if you want all running clients to stop (see top of this file).
clear_all_clients=false

if $clear_all_clients;then
    ray_control script_info "Clearing clients..."
    ray_control clear_clients
    ray_control hide_script_info
fi

# order daemon to load the session
ray_control run_step


# script here some actions to run once the session is loaded.
if [ $? = 0 ]; then
  if pgrep -x "patchage" > /dev/null
  then

    i3-msg "workspace 10"
    sleep 0.5
    i3-msg [class="Patchage"] resize grow width 520px
    sleep 0.5
    xdotool search --onlyvisible --name "Patchage" key ctrl+r
    sleep 0.25
    xdotool search --onlyvisible --name "Patchage" key ctrl+g
    sleep 0.25
    xdotool search --onlyvisible --name "Patchage" key ctrl+f
  fi
fi

bash kill-midi.sh
