#!/bin/bash

if [[ -x "${PREFIX}/bin/openbox" ]]; then
    echo "Starting openbox on $(hostname)..."

    ### VNC Server
    if [[ ! -z "${VNCDESKTOP}" ]]; then
        # polybar
        continue

    ### Local XServer
    elif [[ -z ${SSH_CLIENT+null} ]]; then
        export DISPLAY=:0
        export PULSE_SERVER=tcp:127.0.0.1:4713

    ### Remote XServer
    else
        export DISPLAY=${SSH_CLIENT%% *}:0
        export PULSE_SERVER=tcp:${SSH_CLIENT%% *}:4713
    fi

    ### Set Wallpaper
    if [[ -f "${HOME}/.config/openbox/slime.jpg" ]]; then
        feh --bg-fill "${HOME}/.config/openbox/slime.jpg" &
    fi

    openbox &
fi
