# Notes for Claude

Read NOTES.md first (constraints, decisions, open questions) and README.md.

* Changes are often made on a Windows machine without git, Python or Linux,
  then copied by hand to an Ubuntu 24.04 machine and tested there. Nothing
  can be run here, so be careful and keep configs tolerant of missing programs.
* Target versions are what Ubuntu 24.04 apt ships (i3 4.23, polybar 3.7,
  picom 10, rofi 1.7, dunst 1.9, tmux 3.4, fish 3.7, kitty 0.32), except for
  tools installed from the offline bundle (Neovim 0.11+, newest kitty, fzf, starship,
  uv, pixi).
* Programs not from apt are installed per user without sudo: where the
  program's own installer puts it if it has one, otherwise single files in
  `~/.local/bin` and folders in `~/.local/opt/<name>` + a link in
  `~/.local/bin` (see "Where hand-installed programs go" in docs/SETUP.md).
* Files must use LF line endings, and scripts need a `#!` line
  (`copy_to_home.py` makes them executable).
* Colors come from docs/palette.md. Update docs/keybindings.md when bindings
  change; it only lists keys that can't be discovered in the programs
  themselves (see NOTES.md, round 4). Don't change the user's core bindings.
* The user maintains this without Claude: prefer plain, commented configs
  over clever ones, and record decisions in NOTES.md.
