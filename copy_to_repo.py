#!/usr/bin/env python3
"""Copy the dotfiles listed in `file-list` from the home directory into this repo.

Use this after changing configs on the machine, then review with `git diff`.
Directory entries ("nvim/") copy every file in that directory in the home
directory, so new files there get picked up too.

Usage:
    ./copy_to_repo.py
    ./copy_to_repo.py nvim kitty   only paths containing "nvim" or "kitty"
"""

import os
import shutil
import sys

from copy_to_home import DOTFILES, HOME, expand_file_list


def main():
    filters = sys.argv[1:]
    for path in expand_file_list(HOME):
        if filters and not any(f in path for f in filters):
            continue
        src = os.path.join(HOME, path)
        dst = os.path.join(DOTFILES, path)
        try:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy(src, dst)
            print("{} copied".format(path))
        except OSError as e:
            print("{} FAILED TO COPY: {}".format(path, e))


if __name__ == "__main__":
    main()
