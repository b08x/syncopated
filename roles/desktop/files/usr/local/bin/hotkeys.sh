#!/usr/bin/env bash

export XDG_RUNTIME_DIR="/run/user/${UID}"

killall swhks

swhks & pkexec swhkd -c ~/.config/swhkd/swhkdrc
