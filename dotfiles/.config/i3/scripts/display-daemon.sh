#!/usr/bin/env bash

# Define the lock file
LOCKFILE="/tmp/display-daemon.lock"

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

# Check if we are a laptop with a lid
if [ -f /proc/acpi/button/lid/LID0/state ]; then
    hasLid=true
else
    hasLid=false
fi

# Check output state continuously
while true; do
    # Give the x-server time to start
    sleep 4

    # Get current state witout polling for hardware changes
    xStatus=$(xrandr --current)

    # Parse the highest resolution and state for each connected output
    connectedOutputs=$(awk '
    / connected / {
        connected = 1
        output = $1
        state = match($0, / connected .*[0-9]+x[0-9]+/) ? "enabled" : "disabled"
        primary = match($0, / primary /) ? "primary" : "secondary"
    }
    / disconnected / {
        connected = 0
    }
    connected && /^[[:space:]]+[0-9]+x[0-9]+/ {
        split($1, res, "x")
        if (res[1] > maxWidth[output]) {
            maxWidth[output] = res[1]
            mode[output] = $1 " " output " " state " " primary
        }
    }
    END {
        for (output in mode) {
            print mode[output]
        }
    }' <<< $xStatus | sort -r)

    # If internalOutput is set after this, it should be turned off
    internalOutput=""
    if $hasLid; then
        lidState=$(awk '{print $2}' /proc/acpi/button/lid/LID0/state)
        internalOutput=$(grep -E '(eDP|eDP-[0-9]+|LVDS|LVDS-[0-9]+)' <<< "$connectedOutputs")
        # If the lid is closed and there are external outputs,
        # don't count the internal output as connected (it should be off)
        if [ "$lidState" == "closed" ] && [ "$internalOutput" != "$connectedOutputs" ]; then
            connectedOutputs=$(grep -v "$internalOutput" <<< "$connectedOutputs")
            internalOutput=$(grep "enabled" <<< "$internalOutput")
        else
            internalOutput=""
        fi
    fi

    # Build the xrandr command
    xCommand=""

    # Count active outputs
    activeCount=$(grep "enabled" <<< "$connectedOutputs" | wc -l)

    # If there are no active outputs, or if we are turning off
    # the internal output, activate all connected outputs
    if [ "$activeCount" -eq 0 ] || [ -n "$internalOutput" ]; then
        previous=""
        while read -r output; do
            xCommand+=$(awk '{print "--output " $2 " --mode " $1 " "}' <<< "$output")
            if [ -z "$previous" ]; then
                xCommand+="--primary "
            else
                xCommand+="--right-of $previous "
            fi
            previous=$(awk '{print $2}' <<< "$output")
        done  <<< "$connectedOutputs"
    fi

    # Turn off the internal output if needed
    if [ -n "$internalOutput" ]; then
        xCommand+=$(awk '{print "--output " $2 " --off "}' <<< "$internalOutput)")
    fi

    # Run the command if it is not empty
    if [ -n "$xCommand" ]; then
        echo "Running xrandr command: xrandr $xCommand"
        xrandr $xCommand
    fi
done
