#!/usr/bin/env bash
# Started once by i3 at login. Starts background programs depending on the
# machine profile (see machine-profile.sh). The bar is started separately by
# i3 with exec_always, so that it restarts together with i3.
#
# Log: ~/.cache/i3-autostart.log

exec >"$HOME/.cache/i3-autostart.log" 2>&1

scripts="$HOME/.config/i3/scripts"
profile=$("$scripts/machine-profile.sh")
echo "Machine profile: $profile"

# Start a program in the background if it is installed
run() {
    if command -v "$1" >/dev/null; then
        echo "Starting: $*"
        "$@" &
    else
        echo "Not installed, skipping: $1"
    fi
}

# --- All machines --------------------------------------------------------

# Colors, Xft.dpi (font scale) and font smoothing
"$scripts/load-xresources.sh"

# GNOME theme/font settings for GTK apps
[ -x /usr/libexec/gsd-xsettings ] && /usr/libexec/gsd-xsettings &

# Notifications (start explicitly so that xfce4-notifyd does not win the race)
run dunst

# Password keyring for Chrome and others. Login normally unlocks it already;
# this makes sure it runs under i3 (its autostart entry is GNOME-only).
run gnome-keyring-daemon --start --components=secrets

# XDG autostart .desktop files, https://wiki.archlinux.org/index.php/XDG_Autostart
run dex --autostart --environment i3

# No idle locking (on purpose, see NOTES.md): turn off X's screensaver,
# which would otherwise start after 10 idle minutes and make xss-lock lock.
xset s off
# Lock the screen before suspend
run xss-lock --transfer-sleep-lock -- "$scripts/lock.sh"

# Clipboard history (open with Alt+y)
run copyq

# Caps lock as ctrl, § as ~
"$scripts/keyboard-daemon.sh" &

run numlockx on

# Wallpaper, solid background color as fallback
wallpaper="$HOME/Pictures/wallpaper.jpg"
if [ -f "$wallpaper" ] && command -v feh >/dev/null; then
    feh --no-fehbg --bg-fill "$wallpaper"
else
    xsetroot -solid "#1d2021"
fi

# Compositor, so windows with transparent parts (GTK menus, tooltips) are
# drawn correctly instead of with black corners.
# On a real screen, also draw with the GPU and without tearing. Remote
# desktops usually have no OpenGL, so they get picom's defaults (CPU, no vsync).
# These flags override backend/vsync in picom.conf.
if [ "$profile" = remote ]; then
    run picom
else
    run picom --backend glx --vsync
fi

# --- Physical machines ---------------------------------------------------

if [ "$profile" = laptop ] || [ "$profile" = desktop ]; then
    # Always keep a display enabled when monitors are (un)plugged
    "$scripts/display-daemon.sh" &
    run nm-applet
fi

# --- Laptops -------------------------------------------------------------

if [ "$profile" = laptop ]; then
    run blueman-applet
    # Brightness keys, lid close, suspend. Configure with xfce4-power-manager-settings
    run xfce4-power-manager
fi
