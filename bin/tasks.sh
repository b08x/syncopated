#!/usr/bin/env bash

INVENTORY="${ANSIBLE_HOME}/inventory.ini"
PLAYBOOKS="${ANSIBLE_HOME}/playbooks"

tags=$(ansible-playbook -i $INVENTORY $PLAYBOOKS/full.yml --list-tags | awk -F 'TASK TAGS:' '{print $2}' | xargs |
	xargs | sd '^\[|\]|,' '')

gum choose --no-limit ${tags[@]}

tasks=$(ansible-playbook -i $INVENTORY "${PLAYBOOKS}/full.yml" --list-tasks | awk -F ':' '{print $2}' | awk -F '\t' '{print $1}'| uniq | gum filter --no-limit)

echo $tasks
exit

# for task in "${tasks[@]}"; do
# 	ansible-playbook -i $INVENTORY "${PLAYBOOKS}/full.yml" --start-at-ask="$task" --limit syncopatedos
# done

# alacritty, always, applications, asdf, audio, autofs, autologin, backgrounds, backup, barrier, base, bluetooth, cpupower, deadbeef, desktop, docker, dunst, env, firewall, fonts, full, gnome, groups, grub, gtk, htop, i3, icons, keybindings, keys, kitty, libvirt, lnav, media, menu, mirrors, mixxx, network, networkmanager, nfs, ntp, osc2midi, packages, pacman, picom, pipewire, profile, protokol, pulsar, python, qt, ranger, realtime, reaper, repo, rofi, rsyncd, rtirq, rtkit, ruby, scripts, setup, shell, sonicannotator, soniclineup, ssh, sshd, sudoers, sway, sxhkd, sysctl, terminal, testing, theme, thunar, tony, touchosc, tuned, tuning, updatedb, user, vagrant, vamp, video, vscode, wireless, xdg, xorg, zram
