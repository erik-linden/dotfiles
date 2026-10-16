#!/usr/bin/env bash
# Lock the screen with a Gruvbox styled i3lock.
#
# Uses i3lock-color if installed (clock, colored ring, blurred screen),
# otherwise plain i3lock with a pixelated screenshot (needs imagemagick),
# otherwise plain i3lock with a solid color.
#
# Waits until the screen is unlocked. Extra arguments are passed on to i3lock.

# Already locked?
pgrep -u "$USER" -x i3lock >/dev/null && exit 0

# Pause notifications while locked, so they don't show on the lock screen
command -v dunstctl >/dev/null && dunstctl set-paused true

# Colors from docs/palette.md, as RRGGBBAA
bg=1d2021ff
bg_t=1d2021cc
border=504945ff
fg=d4be98ff
grey=928374ff
yellow=d8a657ff
green=a9b665ff
red=ea6962ff
orange=e78a4eff
clear=00000000

font="JetBrainsMono Nerd Font"

args=(--ignore-empty-password --show-failed-attempts)
image=""

# i3lock-color credits its own authors in the version string
if i3lock --version 2>&1 | grep -qiE 'color|raymond|cassandra'; then
    args+=(
        --blur 8
        --color="$bg"
        --indicator --force-clock
        --radius 110 --ring-width 6
        --inside-color="$bg_t" --ring-color="$border"
        --insidever-color="$bg_t" --ringver-color="$yellow"
        --insidewrong-color="$bg_t" --ringwrong-color="$red"
        --line-color="$clear" --separator-color="$clear"
        --keyhl-color="$green" --bshl-color="$orange"
        --time-str="%H:%M" --time-color="$fg" --time-font="$font" --time-size=40
        --date-str="%A %d %B" --date-color="$grey" --date-font="$font" --date-size=14
        --verif-text="" --wrong-text="" --noinput-text="" --lock-text="" --lockfailed-text=""
        --verif-color="$yellow" --wrong-color="$red" --modif-color="$red"
    )
else
    args+=(--color=1d2021)
    if command -v import >/dev/null && command -v convert >/dev/null; then
        image=$(mktemp --suffix=.png)
        # Pixelate a screenshot (fast, and hides what's on the screen)
        if import -silent -window root "$image" \
            && convert "$image" -scale 5% -fill "#1d2021" -colorize 40% -scale 2000% "$image"; then
            args+=(--image="$image")
        fi
    fi
fi

if [ -n "${XSS_SLEEP_LOCK_FD:-}" ] && [ -e "/dev/fd/$XSS_SLEEP_LOCK_FD" ]; then
    # Started by xss-lock before a suspend. It holds the suspend back until
    # this file descriptor is closed, so: lock (without --nofork, i3lock
    # returns once the screen is locked, and must not get a copy of the fd),
    # then close it so the suspend goes ahead, then wait for the unlock.
    i3lock "${args[@]}" "$@" {XSS_SLEEP_LOCK_FD}<&-
    exec {XSS_SLEEP_LOCK_FD}<&-
    while pgrep -u "$USER" -x i3lock >/dev/null; do
        sleep 0.5
    done
else
    i3lock --nofork "${args[@]}" "$@"
fi

[ -n "$image" ] && rm -f "$image"
command -v dunstctl >/dev/null && dunstctl set-paused false
