# dotfiles

Collection of my Linux configuration files: Ubuntu 24.04, i3, polybar,
picom, rofi, dunst, kitty, tmux, fish + starship, Neovim. Everything uses
JetBrains Mono Nerd Font and the Gruvbox Material Dark Hard colors.

| Path | What |
|---|---|
| `dotfiles/` | The config files, laid out as in `$HOME` |
| `file-list` | Which of them get copied |
| `copy_to_home.py` | Repo → home (asks before overwriting changes, `--dry-run` to preview) |
| `copy_to_repo.py` | Home → repo (then check `git diff`) |
| `scripts/` | Offline bundle: download tools on one machine, install on another |
| `docs/SETUP.md` | Setting up a new machine, or migrating one from the old setup |
| `docs/keybindings.md` | Key bindings across i3, kitty, tmux, nvim, fish, rofi |
| `docs/palette.md` | The color palette and where each color is used |
| `NOTES.md` | Decisions, open questions, ideas, testing checklist |

To add a config file: put it under `dotfiles/` and add its path (or its
directory, ending in `/`) to `file-list`.
