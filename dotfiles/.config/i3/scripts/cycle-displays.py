#!/usr/bin/env python3

import pathlib
import subprocess
import re
import itertools
import dataclasses


@dataclasses.dataclass()
class ActiveMode:
    width: int
    height: int
    x_offset: int
    y_offset: int


@dataclasses.dataclass()
class DisplayInfo:
    name: str
    active_mode: ActiveMode | None
    is_primary: bool
    resolutions: list[tuple[int, int]]


@dataclasses.dataclass()
class Displays:
    connected: list[DisplayInfo]
    disconnected: list[str]


def get_xrandr_output():
    try:
        result = subprocess.run(["xrandr", "--current"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"xrandr error: {result.stderr}")
        return result.stdout
    except FileNotFoundError:
        raise RuntimeError("xrandr is not installed or not in PATH")


def parse_xrandr_output(output):
    displays = []
    lines = output.splitlines()
    disconnected_displays = []
    current_display = None

    for line in lines:
        if " connected " in line:
            # Parse display name and connection status
            match = re.match(r"^(\S+)\s+connected(\s+primary)?(?:\s+(\d+x\d+\+\d+\+\d+))?", line)
            if not match:
                raise ValueError(f"Failed to parse line: {line}")
            display_name = match.group(1)
            is_primary = match.group(2) is not None
            resolution_and_offset = match.group(3)
            if resolution_and_offset is not None:
                mode = ActiveMode(
                    *(map(int, resolution_and_offset.split("+")[0].split("x"))),
                    *(map(int, resolution_and_offset.split("+")[1:])),
                )
            else:
                mode = None
            current_display = DisplayInfo(name=display_name, is_primary=is_primary, active_mode=mode, resolutions=[])
        elif " disconnected " in line:
            if current_display:
                displays.append(current_display)
            current_display = None
            if match := re.match(r"^(\S+)\s+disconnected \s+(\d+x\d+\+\d+\+\d+)", line):
                display_name = match.group(1)
                disconnected_displays.append(display_name)
        elif current_display and (match := re.match(r"^\s+(\d+x\d+)", line)):
            resolution = match.group(1)
            current_display.resolutions.append(tuple(map(int, resolution.split("x"))))
    if current_display:
        displays.append(current_display)

    # Put build-in displays first, then sort by name.
    displays = sorted(displays, key=lambda d: (re.match("(eDP|eDP-[0-9]+|LVDS|LVDS-[0-9]+)", d.name) is None, d.name))

    # If we have a lid and it's closed, removed the built-in
    # display from the list of connected displays.
    lid_state = pathlib.Path("/proc/acpi/button/lid/LID0/state")
    if lid_state.exists() and lid_state.read_text().split()[-1] == "closed":
        disconnected_displays.insert(0, displays.pop(0).name)

    return Displays(displays, disconnected_displays)


def cycle_displays(displays: Displays) -> None:
    connected = displays.connected
    n_connected = len(connected)
    n_active = sum(display.active_mode is not None for display in connected)
    if n_connected == 0:
        print("No display connected.")
        _notify_send("No display connected")
        return
    if n_connected == n_active == 1:
        print("One display connected and active.")
        _notify_send("One display connected and active")
        return
    if n_active == 0:
        print("No display active, activating 0.")
        _notify_send("No display active, activating primary")
        _activate_one(displays, 0)
    elif n_active == 1:
        active_index = [display.active_mode is not None for display in connected].index(True)
        print(f"Display {active_index} is active.")
        if active_index != n_connected - 1:
            _activate_one(displays, active_index + 1)
        else:  # Switch to mirror.
            _activate_both(displays, mirror=True)
    else:  # Multiple active.
        unique_offsets = set(_get_offset(display) for display in connected)
        if unique_offsets == {(0, 0)}:  # Switch to extend.
            print("Displays are mirrored.")
            _activate_both(displays, mirror=False)
        else:  # Switch back to single active.
            print("Displays are extended.")
            _activate_one(displays, 0)


def _get_offset(display: DisplayInfo) -> tuple[int, int]:
    assert display.active_mode is not None
    mode = display.active_mode
    return mode.x_offset, mode.y_offset


def _activate_one(displays: Displays, active: int):
    print(f"Activating display {active}.")
    _notify_send({0: "Primary", 1: "Secondary"}.get(active, f"Display {active + 1}"))
    connected = displays.connected
    disconnected = displays.disconnected
    active = connected[active]
    disabled = [display.name for display in connected if display is not active]
    disabled = disabled + disconnected
    command = " ".join(
        [
            "xrandr",
            _activate_at_highest_resolution_command(active),
            "--primary",
            _disable_all(disabled),
        ]
    )
    print(f"Executing command '{command}'")
    subprocess.check_call(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def _activate_both(displays: Displays, mirror: bool):
    connected = displays.connected
    print("Activate both in " + ("mirror" if mirror else "extend") + " mode")
    _notify_send("Mirror" if mirror else "Extend")
    if mirror:
        combinations = list(itertools.product(*(display.resolutions for display in connected)))
        combination = sorted(combinations, key=_get_mirror_sort_key)[0]
        args = [f"--output {display.name} --mode {r[0]}x{r[1]}" for display, r in zip(connected, combination)]
    else:
        previous = [None] + connected[:-1]
        args = []
        for display, previous in zip(connected, previous):
            args.append(
                _activate_at_highest_resolution_command(display) + (f" --left-of {previous.name}" if previous else "")
            )
    args.insert(0, "xrandr")
    args.insert(2, "--primary")
    args.append(_disable_all(displays.disconnected))
    command = " ".join(args)
    print(f"Executing command '{command}'")
    subprocess.check_call(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def _get_mirror_sort_key(resolutions: tuple[tuple[int, int], ...]) -> tuple[int, int]:
    area_shared = min(r[0] for r in resolutions) * min(r[1] for r in resolutions)
    area_outside = sum(r[0] * r[1] - area_shared for r in resolutions)
    return -area_shared, area_outside


def _activate_at_highest_resolution_command(display: DisplayInfo) -> str:
    resolution = "x".join(map(str, sorted(display.resolutions, key=lambda r: r[0], reverse=True)[0]))
    return f"--output {display.name} --mode {resolution}"


def _disable_all(names: list[str]) -> None:
    return " ".join(f"--output {name} --off" for name in names)


def _notify_send(message: str) -> None:
    subprocess.call(
        [
            "dunstify",
            "--appname",
            "Displays",
            "--hints",
            "string:x-dunst-stack-tag:displays",
            "--icon",
            "video-display",
            message,
        ]
    )


if __name__ == "__main__":
    cycle_displays(parse_xrandr_output(get_xrandr_output()))
