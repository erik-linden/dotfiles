#!/usr/bin/env bash

while true; do
    # Give the x-server time to start
    sleep 3

    # Check it caps lock (0x42) is already set to control
    if [ -z "$(xmodmap | grep "Control_L (0x42)")" ]; then

        # Set caps lock to control
        setxkbmap -option ctrl:nocaps

        # Set the § key to be a tilde
        xmodmap -e "keycode 49 = asciitilde"
    fi
done
