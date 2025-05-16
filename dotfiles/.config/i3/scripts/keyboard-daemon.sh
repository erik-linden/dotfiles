#!/usr/bin/env bash

# Define the lock file
LOCKFILE="/tmp/keyboard-daemon.lock"

# Ensure only one instance of the script is running
if [ -f "$LOCKFILE" ]; then
    # Check if the process in the lock file is still running
    if kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
        echo "Script is already running. Exiting."
        exit 1
    else
        # Remove stale lock file
        echo "Removing stale lock file."
        rm -f "$LOCKFILE"
    fi
fi

# Write the current process ID to the lock file
echo $$ > "$LOCKFILE"

# Function to handle termination signals
cleanup() {
    echo "Display daemon shutting down..."
    rm -f "$LOCKFILE"  # Remove the lock file on exit
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM (kill command) signals
trap cleanup SIGINT SIGTERM

while true; do
    # Give the x-server time to start
    sleep 3

    # Check it caps lock (0x42) is already set to control
    if [ -z "$(xmodmap | grep "Control_L (0x42)")" ]; then
        echo "Setting caps lock to control and § key to tilde."

        # Set caps lock to control
        setxkbmap -option ctrl:nocaps

        # Set the § key to be a tilde
        xmodmap -e "keycode 49 = asciitilde"
    fi
done
