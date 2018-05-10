#!/usr/bin/env python3

from __future__ import print_function

import difflib
import os
import shutil
import sys

_HOME = os.path.abspath(os.path.expanduser("~"))
_REPO = os.path.abspath(os.path.split(__file__)[0])
_PAD = 3


def main():
    with open(os.path.join(_REPO, "file-list")) as f:
        paths = [l.strip() for l in f.readlines()]

    for path in paths:
        _copy(path)


def _copy(path):
    src = os.path.join(_REPO, "dotfiles", path)
    dst = os.path.join(_HOME, path)

    if not os.path.exists(dst):
        dirs = os.path.split(dst)[0]
        if not os.path.exists(dirs):
            os.makedirs(dirs)
        shutil.copy(src, dst)
        print("{} created".format(path))
        return

    src_lines = _read_lines(src)
    dst_lines = _read_lines(dst)

    if src_lines == dst_lines:
        print("{} identical".format(path))
        return

    print("{} differ".format(path))
    patched_lines = _interactive_patch(src_lines, dst_lines)
    _write_lines(dst, patched_lines)


def _read_lines(path):
    with open(path) as f:
        return f.readlines()


def _write_lines(dst, lines):
    with open(dst, "w") as f:
        f.writelines(lines)


def _interactive_patch(src_lines, dst_lines):
    differ = difflib.Differ()
    diff = differ.compare(dst_lines, src_lines)
    diff = list(diff)

    indices = list(range(len(diff)))
    output = []
    while indices:
        i = indices.pop(0)
        if diff[i][:2] != "  ":  # new block
            # roll up the block
            begin = i
            while indices:
                line = diff[indices[0]]
                if line[:2] != "  ":
                    i = indices.pop(0)
                else:  # block ended
                    break
            end = i + 1

            # decide what to do
            while True:
                _print_block(diff, begin, end)

                key = input("Apply change [y, n, q]? ").lower().strip()

                if key not in ["y", "n", "q"]:
                    continue

                if key == "q":
                    sys.exit()

                which = {"n": 1, "y": 2}[key]
                restored = list(difflib.restore(diff[begin:end], which))
                output.extend(restored)

                break

        else:
            output.append(diff[i][2:])

    return output


def _print_block(diff, begin, end):
    print("".join(80 * ["#"]))
    [print(l, end="") for l in diff[max(0, begin - _PAD): begin + 1] if l[:2] == "  "]
    [print(l, end="") for l in diff[begin: end]]
    [print(l, end="") for l in diff[end: min(len(diff), end + _PAD + 1)] if l[:2] == "  "]


if __name__ == "__main__":
    main()
