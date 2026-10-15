#!/usr/bin/env bash
# Give the focused workspace a name, while keeping its number, e.g. "3: docs".
# The `workspace number 3` bindings keep working after the rename.
# An empty name resets the workspace to just its number.

num=$(i3-msg -t get_workspaces | python3 -c '
import json, sys
print(next(w["num"] for w in json.load(sys.stdin) if w["focused"]))
')

name=$(rofi -dmenu -p "Name workspace $num" -theme-str 'listview { enabled: false; }' </dev/null)
# rofi exits non-zero on escape
[ $? -eq 0 ] || exit 0

# Quotes would break the i3 command
name=${name//\"/}

if [ -z "$name" ]; then
    i3-msg "rename workspace to \"$num\"" >/dev/null
else
    i3-msg "rename workspace to \"$num: $name\"" >/dev/null
fi
