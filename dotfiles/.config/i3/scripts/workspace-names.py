#!/usr/bin/env python3
"""Name each i3 workspace after its windows, e.g. "3 vim init.lua | firefox".

Started by the i3 config (exec_always). It listens to i3 and renames the
workspaces whenever a window opens, closes, moves or changes its title, and
when the focus moves to another workspace (the focused one gets a longer
name). The number stays at the front, so `workspace number 3` still works.

Needs python3-i3ipc (apt). It stops by itself when i3 restarts or exits;
exec_always then starts a new one.

Try changes without renaming anything (prints the names it would set):
    ~/.config/i3/scripts/workspace-names.py --dry-run

Find a window's class and title: `xprop WM_CLASS WM_NAME`, then click the
window (the class is the second string of WM_CLASS).
"""

import re
import sys
import traceback

try:
    import i3ipc
except ImportError:
    sys.exit("workspace-names.py: python3-i3ipc is missing (sudo apt install python3-i3ipc)")


# --- Naming rules ---------------------------------------------------------

# Windows whose class and title match get a name made from the title.
# (class regex, title regex, name); \1 in the name is the title's first
# group in parentheses. The first matching rule wins.
#
# nvim sets its own title, "nvim <file> (<folder>)" (nvim/lua/config/
# options.lua); without a file it's "nvim  (<folder>)". For other programs
# fish sets kitty's title: the command line (its first 20 characters) and
# the shell's folder, e.g. "btop ~", or just the folder when nothing runs.
# Nautilus's title is the folder it shows.
TITLE_RULES = [
    ("kitty", r"^nvim (.+) \(.*\)$", r"vim \1"),    # vim and the file
    ("kitty", r"^nvim +\((.*)\)$", r"vim \1"),      # vim and the folder
    ("kitty", r"^n?vim\b", "vim"),                  # vim before it set a title
    ("kitty", r"^(btop|htop|ranger)\b", r"\1"),
    ("kitty", r"^ssh (\S+)", r"ssh \1"),           # ssh and the host
    (r"^org\.gnome\.Nautilus$", r"^(.+)$", r"files \1"),
]

# Names for window classes, (class regex, name). The first match wins.
CLASS_RULES = [
    (r"^Google-chrome$", "chrome"),
    (r"^jetbrains-([a-z]+)", r"\1"),               # jetbrains-pycharm-ce -> pycharm
    (r"^Code$", "code"),
    (r"^org\.gnome\.Nautilus$", "files"),
    (r"^libreoffice", "office"),
]

# Between the window names
SEPARATOR = " | "

# Names longer than this (without the number) are cut and end in "…"
MAX_LENGTH_FOCUSED = 40
MAX_LENGTH_OTHER = 25


def window_name(window):
    """The short name of one window."""
    cls = window.window_class or ""
    title = window.name or ""

    for class_pattern, title_pattern, name in TITLE_RULES:
        if re.search(class_pattern, cls):
            match = re.search(title_pattern, title)
            if match:
                return match.expand(name)

    for class_pattern, name in CLASS_RULES:
        match = re.search(class_pattern, cls)
        if match:
            return match.expand(name)

    # Otherwise a cleaned-up class:
    #   snap apps:        "firefox_firefox"      -> "firefox"
    #   reverse domain:   "com.anthropic.Claude" -> "claude"
    name = cls.split("_")[0].split(".")[-1]
    return name.lower() or "?"


def windows_in(container):
    """All windows below a container, left to right (floating ones last)."""
    if container.window:
        yield container
    for child in container.nodes + container.floating_nodes:
        yield from windows_in(child)


def workspace_name(workspace, focused):
    """The full name for a workspace: its number, then its windows."""
    names = []
    for window in windows_in(workspace):
        name = window_name(window)
        if name not in names:  # two kitty windows: "kitty" once
            names.append(name)

    summary = SEPARATOR.join(names)
    max_length = MAX_LENGTH_FOCUSED if focused else MAX_LENGTH_OTHER
    if len(summary) > max_length:
        summary = summary[: max_length - 1].rstrip() + "…"

    # i3 names are quoted in the rename command: drop quotes and backslashes
    summary = summary.replace('"', "").replace("\\", "")
    return f"{workspace.num} {summary}".strip()


# --- Talking to i3 --------------------------------------------------------

def quote(name):
    """A workspace name as a quoted string for an i3 command."""
    return '"' + name.replace("\\", "\\\\").replace('"', '\\"') + '"'


def update(i3, event=None, dry_run=False):
    """Rename every workspace whose name should change."""
    try:
        tree = i3.get_tree()
        focused = tree.find_focused()
        focused_workspace = focused.workspace() if focused else None
        for workspace in tree.workspaces():
            if workspace.num < 0:  # a workspace without a number: leave it
                continue
            is_focused = focused_workspace is not None and workspace.id == focused_workspace.id
            new = workspace_name(workspace, is_focused)
            if dry_run:
                print(new)
            elif new != workspace.name:
                i3.command(f"rename workspace {quote(workspace.name)} to {quote(new)}")
    except Exception:
        # Keep running; the next event tries again. The message ends up in
        # ~/.cache/workspace-names.log (see the i3 config).
        traceback.print_exc()


def main():
    i3 = i3ipc.Connection()
    if "--dry-run" in sys.argv:
        update(i3, dry_run=True)
        return

    update(i3)
    i3.on(i3ipc.Event.WINDOW_NEW, update)
    i3.on(i3ipc.Event.WINDOW_CLOSE, update)
    i3.on(i3ipc.Event.WINDOW_MOVE, update)
    i3.on(i3ipc.Event.WINDOW_TITLE, update)
    i3.on(i3ipc.Event.WINDOW_FLOATING, update)
    i3.on(i3ipc.Event.WORKSPACE_FOCUS, update)
    i3.on(i3ipc.Event.WORKSPACE_INIT, update)
    i3.on(i3ipc.Event.WORKSPACE_MOVE, update)
    i3.main()  # returns when i3 restarts or exits


if __name__ == "__main__":
    main()
