#!/usr/bin/env python3
"""Copy the dotfiles listed in `file-list` from this repo to the home directory.

For each file you decide what happens:
  new files      create it, or skip it
  changed files  the differences are shown block by block, and you choose
                 which blocks to apply (red "-" lines are in your home
                 directory and get replaced, green "+" lines come from the repo)

Usage:
    ./copy_to_home.py              interactive
    ./copy_to_home.py --dry-run    only show what would happen
    ./copy_to_home.py --yes        apply everything without asking
    ./copy_to_home.py nvim kitty   only paths containing "nvim" or "kitty"

`file-list` format: one path per line, relative to the home directory.
A path ending in "/" means every file in that directory. Lines starting
with "#" are comments.

Files are never deleted; remove retired configs by hand.
"""

import argparse
import difflib
import os
import shutil
import sys

# Also used by copy_to_repo.py
HOME = os.path.abspath(os.path.expanduser("~"))
REPO = os.path.abspath(os.path.dirname(__file__))
DOTFILES = os.path.join(REPO, "dotfiles")

_PAD = 3
_SKIP = ("__pycache__", ".pyc")


# --- Output ----------------------------------------------------------------

_COLOR = sys.stdout.isatty() and "NO_COLOR" not in os.environ


def _style(code):
    return lambda text: "\033[{}m{}\033[0m".format(code, text) if _COLOR else text


red = _style("31")
green = _style("32")
yellow = _style("33")
blue = _style("34")
dim = _style("2")
bold = _style("1")


def ask(question, choices):
    """Ask until one of `choices` (single letters) is typed. No default, so Enter can't apply anything by mistake."""
    while True:
        try:
            answer = input("{} [{}] ".format(question, "/".join(choices))).strip().lower()
        except EOFError:
            answer = "q"
        if len(answer) == 1 and answer in choices:
            return answer
        print(dim("  y = yes, n = no, a = all, s = skip file, q = quit"))


# --- Main ------------------------------------------------------------------


class Stats:
    def __init__(self):
        self.created = []
        self.updated = []
        self.skipped = []
        self.unchanged = 0
        self.missing = []


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", "-n", action="store_true", help="only show what would happen")
    parser.add_argument("--yes", "-y", action="store_true", help="apply everything without asking")
    parser.add_argument("filters", nargs="*", help="only paths containing one of these strings")
    args = parser.parse_args()

    stats = Stats()
    state = {"all_new": args.yes}
    try:
        for path in expand_file_list(DOTFILES, stats):
            if args.filters and not any(f in path for f in args.filters):
                continue
            _copy(path, args, state, stats)
    except KeyboardInterrupt:
        print()
    _print_summary(stats, args.dry_run)


def read_file_list():
    """Return the entries in file-list, without comments and blank lines."""
    with open(os.path.join(REPO, "file-list")) as f:
        lines = [line.strip() for line in f]
    return [line for line in lines if line and not line.startswith("#")]


def expand_file_list(base, stats=None):
    """Return all file paths in file-list, with directories expanded using the files in `base`."""
    paths = []
    for entry in read_file_list():
        if entry.endswith("/"):
            directory = os.path.join(base, entry)
            if not os.path.isdir(directory):
                if stats is not None:
                    stats.missing.append(entry)
                continue
            for root, dirs, files in os.walk(directory):
                dirs[:] = sorted(d for d in dirs if not d.endswith(_SKIP))
                for name in sorted(files):
                    if not name.endswith(_SKIP):
                        paths.append(os.path.relpath(os.path.join(root, name), base))
        else:
            paths.append(entry)
    return paths


def _copy(path, args, state, stats):
    src = os.path.join(DOTFILES, path)
    dst = os.path.join(HOME, path)

    if not os.path.exists(src):
        stats.missing.append(path)
        return

    # --- New file ---
    if not os.path.exists(dst):
        print("{} {}".format(green("+ new    "), path))
        if args.dry_run:
            stats.created.append(path)
            return
        if not state["all_new"]:
            answer = ask("  Create it?", "ynaq")
            if answer == "q":
                raise KeyboardInterrupt
            if answer == "n":
                stats.skipped.append(path)
                return
            if answer == "a":
                state["all_new"] = True
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy(src, dst)  # Also copies the executable bit
        stats.created.append(path)
        return

    # --- Existing file ---
    src_lines = _read_lines(src)
    dst_lines = _read_lines(dst)

    if src_lines == dst_lines:
        stats.unchanged += 1
        return

    print("{} {}".format(yellow("~ changed"), path))
    if args.dry_run:
        for line in difflib.unified_diff(dst_lines, src_lines, "home/" + path, "repo/" + path):
            _print_diff_line(line)
        stats.updated.append(path)
        return

    patched_lines = src_lines if args.yes else _interactive_patch(src_lines, dst_lines)
    if patched_lines is None or patched_lines == dst_lines:
        stats.skipped.append(path)
    else:
        _write_lines(dst, patched_lines)
        stats.updated.append(path)


def _print_summary(stats, dry_run):
    print()
    print(bold("Summary" + (" (dry run, nothing changed)" if dry_run else "")))
    verb = "would be " if dry_run else ""
    for label, paths, color in [
        (verb + "created", stats.created, green),
        (verb + "updated", stats.updated, yellow),
        ("skipped", stats.skipped, dim),
        ("missing in repo", stats.missing, red),
    ]:
        if paths:
            print(color("  {:<20} {}".format(label, len(paths))))
            for path in paths:
                print(dim("      " + path))
    print(dim("  {:<20} {}".format("unchanged", stats.unchanged)))


# --- Files -----------------------------------------------------------------


def _read_lines(path):
    with open(path, encoding="utf-8") as f:
        return f.readlines()


def _write_lines(dst, lines):
    with open(dst, "w", encoding="utf-8") as f:
        f.writelines(lines)


# --- Interactive patching ----------------------------------------------------


def _interactive_patch(src_lines, dst_lines):
    """Ask block by block. Returns the new lines, or None to leave the file alone."""
    diff = [line for line in difflib.Differ().compare(dst_lines, src_lines) if not line.startswith("? ")]
    blocks = _count_blocks(diff)

    output = []
    apply_all = False
    block = 0
    i = 0
    while i < len(diff):
        if diff[i][:2] == "  ":
            output.append(diff[i][2:])
            i += 1
            continue

        # A block of consecutive changed lines
        begin = i
        while i < len(diff) and diff[i][:2] != "  ":
            i += 1
        end = i
        block += 1

        if apply_all:
            answer = "y"
        else:
            _print_block(diff, begin, end, block, blocks)
            answer = ask("  Apply this change?", "ynasq")
        if answer == "q":
            raise KeyboardInterrupt
        if answer == "s":
            return None
        if answer == "a":
            apply_all = True
            answer = "y"

        which = {"n": 1, "y": 2}[answer]
        output.extend(difflib.restore(diff[begin:end], which))

    return output


def _count_blocks(diff):
    count = 0
    previous_changed = False
    for line in diff:
        changed = line[:2] != "  "
        if changed and not previous_changed:
            count += 1
        previous_changed = changed
    return count


def _print_block(diff, begin, end, block, blocks):
    print(blue("  ── change {} of {} ".format(block, blocks) + "─" * 50))
    # Context: up to _PAD unchanged lines on each side. It stops at a
    # neighboring change, since whether its lines end up in the file depends
    # on the answer to that change.
    before = _unchanged(reversed(diff[max(0, begin - _PAD) : begin]))[::-1]
    after = _unchanged(diff[end : end + _PAD])
    for line in before:
        print(dim("    " + line[2:].rstrip("\n")))
    for line in diff[begin:end]:
        _print_diff_line(line, indent="    ")
    for line in after:
        print(dim("    " + line[2:].rstrip("\n")))


def _unchanged(lines):
    """The lines before the first changed one."""
    result = []
    for line in lines:
        if line[:2] != "  ":
            break
        result.append(line)
    return result


def _print_diff_line(line, indent=""):
    text = indent + line.rstrip("\n")
    if line.startswith(("+++", "---")):
        print(bold(text))
    elif line.startswith("+"):
        print(green(text))
    elif line.startswith("-"):
        print(red(text))
    elif line.startswith("@@"):
        print(blue(text))
    else:
        print(dim(text))


if __name__ == "__main__":
    main()
