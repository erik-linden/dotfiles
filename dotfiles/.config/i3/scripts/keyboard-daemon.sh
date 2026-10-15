#!/usr/bin/env bash
# Keep caps lock as ctrl and § as ~. The settings get lost when a keyboard is
# plugged in (or a remote desktop session reconnects), so re-apply them.

# Ensure only one instance of the script is running
LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/keyboard-daemon.lock"
if [ -f "$LOCKFILE" ]; then
    if kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
        echo "Script is already running. Exiting."
        exit 1
    else
        echo "Removing stale lock file."
        rm -f "$LOCKFILE"
    fi
fi
echo $$ > "$LOCKFILE"

cleanup() {
    echo "Keyboard daemon shutting down..."
    rm -f "$LOCKFILE"
    exit 0
}
trap cleanup SIGINT SIGTERM

while true; do
    # Give the x-server time to start
    sleep 3

    # Check if caps lock (0x42) is already set to control
    if ! xmodmap | grep -q "Control_L (0x42)"; then
        echo "Setting caps lock to control and § key to tilde."

        # Set caps lock to control
        setxkbmap -option ctrl:nocaps

        # Set the § key to be a tilde
        xmodmap -e "keycode 49 = asciitilde"
    fi
done
