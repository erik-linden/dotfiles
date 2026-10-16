#!/usr/bin/env bash
# Start one polybar per monitor. Called by i3 (exec_always) on start and restart.
# The modules shown on the right depend on the machine profile.
# Log: ~/.cache/polybar-<monitor>.log

# Terminate already running bar instances
polybar-msg cmd quit >/dev/null 2>&1
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.1; done

# The bar reads Xft.dpi; make sure it's loaded (this may run before autostart.sh)
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

profile=$("$HOME/.config/i3/scripts/machine-profile.sh")

case "$profile" in
    laptop)  modules="filesystem memory cpu pulseaudio wlan eth battery date" ;;
    desktop) modules="filesystem memory cpu pulseaudio eth date" ;;
    *)       modules="filesystem memory cpu date" ;;
esac

if ! command -v polybar >/dev/null; then
    i3-nagbar -t warning -m "polybar is not installed: sudo apt install polybar" &
    exit 1
fi

# "DP-1: 2560x1440+0+0 (primary)" -> one bar per monitor, the tray goes on the primary one
polybar --list-monitors | while IFS= read -r line; do
    monitor=${line%%:*}
    if [[ $line == *primary* ]] || [ "$(polybar --list-monitors | wc -l)" -eq 1 ]; then
        right="$modules tray"
    else
        right="$modules"
    fi
    MONITOR=$monitor MODULES_RIGHT=$right polybar --reload main >"$HOME/.cache/polybar-$monitor.log" 2>&1 &
    disown
done
