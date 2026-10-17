#!/usr/bin/env bash
# Print the profile of the machine we are running on, one of:
#   laptop   physical machine with a battery (wifi, bluetooth, lid, external displays)
#   desktop  physical machine without a battery
#   remote   virtual machine and/or a remote desktop session
#
# To force a profile, write it to ~/.config/machine-profile, e.g.
#   echo remote > ~/.config/machine-profile

override="$HOME/.config/machine-profile"
if [ -r "$override" ]; then
    forced=$(head -n1 "$override" | tr -d '[:space:]')
    case "$forced" in
        laptop | desktop | remote)
            echo "$forced"
            exit 0
            ;;
        *)
            # A typo would otherwise mean different things to different
            # scripts; detect the profile as usual instead
            echo "machine-profile.sh: ignoring \"$forced\" in $override (not laptop, desktop or remote)" >&2
            ;;
    esac
fi

# Remote desktop sessions (xrdp, ThinLinc, NoMachine, X2Go)
if [ -n "$XRDP_SESSION" ] || [ -n "$TLSESSIONDATA" ] || [ -n "$NXSESSIONID" ] || [ -n "$X2GO_SESSION" ]; then
    echo remote
    exit 0
fi

# Virtual machines
if command -v systemd-detect-virt >/dev/null && systemd-detect-virt --quiet --vm; then
    echo remote
    exit 0
fi

if compgen -G "/sys/class/power_supply/BAT*" >/dev/null; then
    echo laptop
else
    echo desktop
fi
