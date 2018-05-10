#!/usr/bin/env python3

from __future__ import print_function

import os
import shutil

_HOME = os.path.abspath(os.path.expanduser("~"))
_REPO = os.path.abspath(os.path.split(__file__)[0])


def main():
    with open(os.path.join(_REPO, "file-list")) as f:
        paths = [l.strip() for l in f.readlines()]

    for path in paths:
        try:
            _copy(path)
            print("{} copied".format(path))
        except IOError:
            print("{} FAILED TO COPY".format(path))


def _copy(path):
    src = os.path.join(_HOME, path)
    dst = os.path.join(_REPO, "dotfiles", path)

    dirs = os.path.split(dst)[0]
    if not os.path.exists(dirs):
        os.makedirs(dirs)

    shutil.copy(src, dst)


if __name__ == "__main__":
    main()
