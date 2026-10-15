#!/usr/bin/env bash
# Lock the screen with a Gruvbox styled i3lock.
#
# Uses i3lock-color if installed (clock, colored ring, blurred screen),
# otherwise plain i3lock with a pixelated screenshot (needs imagemagick),
# otherwise plain i3lock with a solid color.
#
# Always runs in the foreground (--nofork), which xss-lock needs.
# Extra arguments are passed on to i3lock.

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

# i3lock-color credits its own authors in the version string
if i3lock --version 2>&1 | grep -qiE 'color|raymond|cassandra'; then
    i3lock --nofork \
        --ignore-empty-password \
        --show-failed-attempts \
        --blur 8 \
        --color="$bg" \
        --indicator --force-clock \
        --radius 110 --ring-width 6 \
        --inside-color="$bg_t" --ring-color="$border" \
        --insidever-color="$bg_t" --ringver-color="$yellow" \
        --insidewrong-color="$bg_t" --ringwrong-color="$red" \
        --line-color="$clear" --separator-color="$clear" \
        --keyhl-color="$green" --bshl-color="$orange" \
        --time-str="%H:%M" --time-color="$fg" --time-font="$font" --time-size=40 \
        --date-str="%A %d %B" --date-color="$grey" --date-font="$font" --date-size=14 \
        --verif-text="" --wrong-text="" --noinput-text="" --lock-text="" --lockfailed-text="" \
        --verif-color="$yellow" --wrong-color="$red" --modif-color="$red" \
        "$@"
else
    image=""
    if command -v import >/dev/null && command -v convert >/dev/null; then
        image=$(mktemp --suffix=.png)
        # Pixelate a screenshot (fast, and hides what's on the screen)
        import -silent -window root "$image" \
            && convert "$image" -scale 5% -fill "#1d2021" -colorize 40% -scale 2000% "$image" \
            || image=""
    fi

    if [ -n "$image" ]; then
        i3lock --nofork --ignore-empty-password --show-failed-attempts \
            --color=1d2021 --image="$image" "$@"
        rm -f "$image"
    else
        i3lock --nofork --ignore-empty-password --show-failed-attempts \
            --color=1d2021 "$@"
    fi
fi

command -v dunstctl >/dev/null && dunstctl set-paused false
