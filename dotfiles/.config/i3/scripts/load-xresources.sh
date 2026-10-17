#!/usr/bin/env bash
# Load ~/.Xresources (colors, Xft.dpi font scale, font smoothing). The login
# normally does this, but not every session type (e.g. remote desktops)
# does. Called by autostart.sh and polybar/launch.sh, whichever runs first.

[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# Over a remote desktop, subpixel font smoothing (Xft.rgba: rgb) turns into
# colored fringes around text, because the picture is compressed on the way.
# Plain grayscale smoothing looks clean there.
if [ "$("$HOME/.config/i3/scripts/machine-profile.sh")" = remote ]; then
    echo "Xft.rgba: none" | xrdb -merge
fi
