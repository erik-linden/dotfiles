#!/usr/bin/env bash

# Ensure only one instance of the script is running
if pidof -o %PPID -x "$(basename "$0")" >/dev/null; then
    echo "Script is already running. Exiting."
    exit 1
fi

# Start monitoring for new input devices
udevadm monitor --subsystem-match=input --property | awk '
    BEGIN { RS = ""; FS = "\n" }
    /ACTION=add/ && /ID_INPUT_KEYBOARD=1/ {
        system("setxkbmap -option ctrl:nocaps")
    }
'