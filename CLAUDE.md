# Notes for Claude

Read NOTES.md first (constraints, decisions, open questions) and README.md.

* Work happens on an Ubuntu 24.04 machine with git, so changes can be
  tested before they are committed. Configs should still tolerate missing
  programs: not every machine has everything installed.
* Target versions are what Ubuntu 24.04 apt ships (i3 4.23, polybar 3.7,
  picom 10, rofi 1.7, dunst 1.9, tmux 3.4, fish 3.7, kitty 0.32), except for
  tools installed from the offline bundle or their own installers (Neovim
  0.11+, newest kitty, fzf, starship, uv, pixi).
* Machines with and without internet are both supported. Don't hard-code
  "no internet" into configs; offline-only steps belong in docs/SETUP.md,
  marked as such.
* Programs not from apt are installed per user without sudo: where the
  program's own installer puts it if it has one, otherwise single files in
  `~/.local/bin` and folders in `~/.local/opt/<name>` + a link in
  `~/.local/bin` (see "Where hand-installed programs go" in docs/SETUP.md).
* Colors come from docs/palette.md. Terminal programs should use the
  terminal's colors (named ANSI colors) where they can, instead of hex values.
* Update docs/keybindings.md when bindings change; it only lists keys that
  can't be discovered in the programs themselves (see NOTES.md, round 4).
  Don't change the user's core bindings.
* The user maintains this without Claude: prefer plain, commented configs
  over clever ones, and record decisions in NOTES.md.
