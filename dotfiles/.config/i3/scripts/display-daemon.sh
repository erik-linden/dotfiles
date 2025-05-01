#!/usr/bin/env bash

# Ensure only one instance of the script is running
if pidof -o %PPID -x "$(basename "$0")" >/dev/null; then
    echo "Script is already running. Exiting."
    exit 1
fi

while true; do
    xStatus=$(xrandr --current)

    # Detect active outputs
    activeOutputs=$(awk '/ connected [^(]/ {print $1}' <<< "$xStatus")

    # Detect the built-in display name (e.g., eDP-1, LVDS-1)
    builtInDisplay=$(awk '/^(eDP|eDP-[0-9]+|LVDS|LVDS-[0-9]+) connected/ {print $1}' <<< "$xStatus")

	# Check if the laptop lid is open
	if [ -f /proc/acpi/button/lid/LID0/state ]; then
		lidState=$(awk '{print $2}' /proc/acpi/button/lid/LID0/state)
	else
		lidState="unknown"
	fi

	# Exclude the built-in display from active outputs if the lid is closed
	if [ "$lidState" == "closed" ]; then
		activeOutputs=$(echo "$activeOutputs" | grep -v "$builtInDisplay")
	fi

    activeCount=$(wc -w <<< "$activeOutputs")

    if [ "$activeCount" -eq 0 ]; then
        if [ -n "$builtInDisplay" ] && [ "$lidState" == "closed" ]; then
            # Activate all displays except the built-in display
            xrandr --auto --output "$builtInDisplay" --off
        else
            # Activate all displays (including the built-in display if applicable)
            xrandr --auto
        fi
    fi

    sleep 3
done