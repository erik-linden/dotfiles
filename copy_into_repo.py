#!/usr/bin/env python3

from __future__ import print_function

import os
import shutil


def main():
    paths = [
        ".gitconfig",
        ".inputrc",
        ".bashrc",
        ".tmux.conf",
        ".vimrc",
        ".config/terminator/config",
        ".config/powerline/config.json"
    ]

    for path in paths:
        try:
            _copy(path)
            print("Copied \"{}\"".format(path))
        except IOError:
            print("FAILED TO COPY \"{}\"".format(path))


def _copy(path):
    home = os.path.abspath(os.path.expanduser("~"))
    here = os.path.abspath(os.path.split(__file__)[0])

    src = os.path.join(home, path)
    dst = os.path.join(here, "dotfiles", path)

    dirs = os.path.split(dst)[0]
    if not os.path.exists(dirs):
        os.makedirs(dirs)

    shutil.copy(src, dst)


if __name__ == "__main__":
    main()
