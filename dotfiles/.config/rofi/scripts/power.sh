#!/usr/bin/env bash
# rofi script mode: power menu. Used as `rofi -show power`, see config.rasi.
# rofi calls this without arguments to get the entries, and with the chosen
# entry as argument to run it.

lock="󰌾 Lock"
logout="󰍃 Logout"
suspend="󰤄 Suspend"
reboot="󰜉 Reboot"
poweroff="󰐥 Shutdown"

# Run detached, so rofi can close
detach() {
    setsid -f "$@" >/dev/null 2>&1
}

case "$1" in
    "")
        printf '%s\n' "$lock" "$logout" "$suspend" "$reboot" "$poweroff"
        ;;
    "$lock")     detach "$HOME/.config/i3/scripts/lock.sh" ;;
    "$logout")   detach i3-msg exit ;;
    "$suspend")  detach systemctl suspend ;;
    "$reboot")   detach systemctl reboot ;;
    "$poweroff") detach systemctl poweroff ;;
esac
