# Notes

Decisions, open questions and ideas for this setup. Newest first.

## Constraints

* Main machine: Ubuntu 24.04, used **over a remote desktop**, one screen, no
  wifi/bluetooth/battery. Internal apt and pip mirrors (they lag a bit and
  sometimes lack dependencies). Other files have to be copied in by hand.
* No laptop any more. The laptop parts (machine profile, display scripts,
  battery/wifi in the bar) are kept but untested; don't spend effort there.
* Changes are often written on another machine and tested later, so configs
  should **degrade gracefully** when a program is missing.
* The repo is public: no internal URLs, host names or credentials. Use
  `<placeholders>` in the docs.
* PyCharm uses the **Eclipse keymap** (lots of `Alt+Shift+<letter>`), so i3
  must not grab more of those.
* No global tool configs (ruff, black...): settings belong in each project.
* The remote desktop is **ThinLinc**, used in a window (the local browser is
  needed). Windowed, ThinLinc does **not** send `Super` or `Alt+Tab` to
  Linux; only full screen does (F8 opens the client menu). The local Windows
  machine is locked down: no executables at all (no PowerToys/AutoHotkey),
  and IT has not remapped caps lock or the Windows key. So: `Super` is a
  bonus, daily things need `Alt` bindings.
* Not wanted: key repeat tweaks, fixed workspaces per app, idle locking (not
  locking is intentional), Gruvbox in PyCharm (its dark theme is close
  enough; 1/3 of the time is in the browser, 1/3 in PyCharm).

## Decisions

### 2026-10 round 12: first test on a real Ubuntu 24.04 (VM)

* The bundle fetches and installs cleanly and 28 parsers build. The
  `install_info.path` assumption from round 11 holds. `dtd` (needed by
  `xml`) was downloaded at install time since it wasn't in parsers.lua;
  now it's listed, and a full install downloads nothing.
* **The gitcommit parser froze a VM**: gcc with `-Wall` (which
  `tree-sitter build` always adds) needs ~4.7 GB of RAM for its
  `parser.c`; `-Wno-uninitialized` brings that down to ~0.5 GB.
  install-bundle.sh sets `CFLAGS=-Wno-uninitialized` for the build; whole
  build now peaks at ~0.8 GB and takes ~10 s. A later `:TSUpdate` inside
  nvim doesn't get the flag, so run install-bundle.sh again instead on a
  small machine.
* `lazy-lock.json` is committed (created by the first fetch), so later
  bundles get the same plugin versions.
* With the apt versions, every config loads without errors: `i3 -C`,
  `rofi -dump-config`/`-dump-theme`, `picom --diagnostics`, polybar
  `--dump` (all modules named in launch.sh exist), `fish -n` + interactive
  start (fzf, `jk` bindings), tmux `source-file`, kitty 0.32 and 0.49.
  shellcheck has only style notes, mostly in the laptop scripts.
  Not tested (needs a real i3 login): autostart.sh, lock.sh, dunst,
  key bindings, the look.
* Don't check versions with `rofi --version` (unknown flag, opens rofi)
  or `i3lock --version` (could lock the screen): use
  `dpkg-query -W <package>`.

### 2026-10 round 11: treesitter parsers built on the target

* The target can be any Linux, so parsers (compiled C) must be built there,
  not on the fetch machine. fetch-offline-bundle.sh only downloads their
  sources (versions pinned by nvim-treesitter, listed by
  scripts/list-parser-sources.lua) into `parser-sources.tar.gz`; the fetch
  machine needs no compiler.
* install-bundle.sh unpacks them to `~/.local/share/nvim/parser-sources/`,
  installs `tree-sitter`, and builds the parsers with nvim (needs `cc` from
  build-essential and the nvim config).
* plugins/treesitter.lua: if that folder exists, each parser's source is
  pointed at it (`install_info.path`), so `:TSUpdate` also works offline.
  Without the folder (online machines), parsers download as usual.
* Untested assumption: nvim-treesitter's `main` branch accepts
  `install_info.path` for local sources. If not, the fallback is regex
  highlighting.

### 2026-10 round 10: picom without effects

* The desktop stays plain: no shadows, fading, transparency, dimming,
  rounded corners, gaps or animations (visual noise, lost space; inactive
  windows are read often, the i3 frame shows focus).
* picom still runs, only so GTK windows with transparent parts render
  correctly. picom.conf explicitly turns shadows and fading off, because
  without a user config picom uses Ubuntu's /etc/xdg/picom.conf, which has
  them on. autostart.sh keeps the remote/physical switch: GPU + vsync
  (tear-free) on a real screen, picom's defaults over a remote desktop.

### 2026-10 round 9: one place for hand-installed programs

* Single user, so everything not from apt goes in the home folder, no sudo.
  First choice: the place the program's own installer/docs use (kitty
  `~/.local/kitty.app`, pixi `~/.pixi/bin`, uv `~/.local/bin`, rustup,
  JetBrains Toolbox), so paths match the documentation. Otherwise
  single-file programs in `~/.local/bin`, folders in `~/.local/opt/<name>`
  with a link in `~/.local/bin` (Neovim, Fiji, p4merge). Exception:
  i3lock-color (system-wide, needs PAM).

### 2026-10 round 8: colors in pagers

* `LESS=-FR` (fish and bash): `less` keeps colors from pipes and quits if
  everything fits. Setting `LESS` stops git from adding its own `FRX`;
  `-F`/`-R` are the parts worth keeping.
* **bat** (apt, `batcat` linked as `~/.local/bin/bat`), theme `gruvbox-dark`
  like delta. Man pages through bat (`MANPAGER`, with `MANROFFOPT=-c`).
* `h <command>` shows `--help` through bat. Named `h` because fish already
  has `help` (opens the fish docs).
* `expect` installed for `unbuffer` (makes programs keep colors in pipes).

### 2026-10 round 7: setup guide

* docs/SETUP.md reordered so nothing is used before it is installed:
  certificate and mirrors first, git before cloning the dotfiles, uv
  mirrors before `uv tool install`.
* The work machine is set up **from scratch**, so the guide has no
  migration steps. Leftovers on an old machine (`~/.config/ruff`,
  `~/.npm-global`, fish's universal `fish_user_paths`...) can just be deleted.
* `.Xresources` is merged at startup (autostart.sh and polybar's
  launch.sh), since remote desktop sessions may not load it.
* Removed from the guide: the inotify step (no problems in years), and how
  to pick i3 as the ThinLinc session (the user edits the session files).
* Bazel via bazelisk (installed as `bazel`), p4merge kept (3-way view) with
  the version as a variable. CUDA note: pixi brings CUDA per project, so the
  system may only need the driver.

### 2026-10 round 6: cleanup

* `.gitconfig`: removed settings that were git defaults (`[color]` auto/ui,
  `push.default`) or not real options (`merge.keepBackup`, per-tool
  `keepTemporaries`/`keepBackup`), and `[color "diff"]` (delta draws diffs).
* fish: removed `NO_AT_BRIDGE` (old GTK warning workaround) and npm's path
  (npm is not used).
* `.gitignore`: GitHub's Python template replaced with a few lines.
* Chrome: `--password-store=basic` → GNOME keyring (`gnome-libsecret`),
  keyring started in autostart.sh. Setup steps for the launcher and the
  keyring password are in docs/SETUP.md.
* starship.toml keeps the Nerd Font symbols preset: starship has no way to
  include a preset, so the symbols have to be in the file.

### 2026-10 round 5: desktop look and feel

* git email moved out of the repo into `~/.gitconfig.local` (included at
  the end of `.gitconfig`; `useConfigOnly` refuses to commit without it).
* Clipboard history: **CopyQ** (apt), `Alt+y`, started by autostart.sh.
* Power menu also on `Alt+x` (Super doesn't reach Linux in windowed ThinLinc).
* One scale for fonts: `Xft.dpi` in `.Xresources`. i3 and polybar use size
  9, a step below kitty/dunst (10) and rofi (11).
* GTK dark mode via `gsettings` (Yaru-dark), no theme install.
* Window borders stay at `normal 5`: thick enough to see the split
  direction indicator.

### 2026-10 round 4: key bindings

* Comfort zone (strongest first): i3 > vim > tmux. Core daily keys: i3 terminal,
  splits, focus/move, workspaces, close, tabbed/split, parent, system menu,
  workspace to monitor, rofi; fish Tab/Up/Ctrl+r/Ctrl+t; vim basics, `jk`,
  `,w`, `,f`, `,Enter`, `Ctrl+n`, `Ctrl+p`. Don't move these.
* `jj` removed everywhere, `jk` is the only escape.
* Window keys share letters, only the prefix differs (i3 `Alt`, tmux
  `Ctrl+a`, nvim `Ctrl+w`): `i` new beside, `n` new below, `h/j/k/l` focus,
  `q` close, `f` zoom (tmux). i3's letters were kept since i3 is the
  strongest habit. tmux keeps `|`/`-` too.
* Same pattern in all three: plain = focus, Shift = move, `r` = resize mode
  (tmux got `Ctrl+a r` and `Ctrl+a Shift+h/j/k/l`; nvim has `Ctrl+w H/J/K/L`
  built in). `Esc` leaves every mode, including tmux copy mode.
* rofi power menu stays (nicer than the i3 system mode); `Super+Escape` locks.
* No text width settings (removed the old 120 too): the programs' defaults are used until it's clear what's wanted.
* `Ctrl+p` finds files in both fish and nvim.
* docs/keybindings.md lists what can't be discovered from the programs
  themselves; discoverable things (rofi tabs, which-key, help screens) are
  only pointed to. Keep it short, so it stays maintained.

### 2026-10 round 3

* git diffs with **delta** instead of diff-highlight (`.gitconfig` `[delta]`).
* `copy_to_home.py`: colors, asks before creating new files, more choices
  per file (s = skip the whole file), and a summary at the end.
* apt list split into groups with a comment on what each package is for.
  Desktop packages are only in section 8. Dropped `jq` (unused) and
  `libtool-bin` (was for building vim/Neovim from source).
* uv: `system-certs = true` (`native-tls` is the deprecated name).
* ranger: small `rc.conf` (kitty image previews, git status), `rcd` fish
  function, key reference in docs/keybindings.md.
* kitty `update_check_interval 0` stays: the check only shows a
  notification. Bundle installs are updated by re-running the bundle, apt
  installs by apt.

### 2026-10 round 2

* Removed the global `~/.config/ruff/pyproject.toml` and `~/.config/black`.
  **Delete them on each machine by hand**, `copy_to_home.py` never deletes:
  `rm -r ~/.config/ruff ~/.config/black`
* Internal mirror/certificate URLs replaced with placeholders in docs/SETUP.md.
* fish is not the login shell on purpose (fish recommends against it), not
  because of LDAP. kitty and tmux start it.
* i3: rename workspace moved to `Super+w` and the power menu to `Super+x`
  only. Both had been on `Alt+Shift+n/x`, which are Eclipse "New"/"Run As".
* i3: `hide_edge_borders smart`.
* zoxide added (apt), in fish and bash.
* tmux: `Ctrl+a Space` opens a menu with the common actions, the status bar
  shows a hint, and `Ctrl+a ?` describes the custom keys.

### 2026-10 big overhaul

| Topic | Decision | Why |
|---|---|---|
| Terminal | terminator → **kitty** | GPU rendering, ligatures, undercurl, hints kitten, image support |
| Bar | i3bar + i3status → **polybar** | Shows workspace names, clickable modules, window title in the middle, tray. In apt. Old i3bar block kept, commented out, in the i3 config. |
| Compositor | **picom**, no effects (see round 10) | Needed so GTK windows with transparent parts aren't drawn with black corners. |
| Machine profiles | `machine-profile.sh` → laptop/desktop/remote | One config for both machines. Force with `~/.config/machine-profile`. |
| Lock screen | `lock.sh`: i3lock-color if built, else pixelated screenshot | i3lock-color is not in apt. |
| Launcher | rofi with more modes (files, ssh, power menu, keys) on `Super` | |
| Editor | vim → **Neovim 0.11+** with lazy.nvim | `.vimrc` kept for plain vim. |
| Plugins | gitgutter→gitsigns, css-color→nvim-highlight-colors, ALE→LSP + conform, fzf.vim→fzf-lua, nerdtree→nvim-tree, airline→lualine, YCM→blink.cmp | Maintained Lua plugins. No compiling YCM. |
| Python LSP | ruff + basedpyright via `uv tool install` | Available through the pip mirror, no node/npm needed. |
| Python envs | conda → **uv** (projects, tools) + **pixi** (conda-forge needs) | |
| pip | `require-virtualenv = true` in `~/.config/pip/pip.conf` | |
| Offline installs | `scripts/fetch-offline-bundle.sh` + `install-bundle.sh` | Same path for online and offline. Everything goes into `~/.local`, no sudo. |
| Colors | One palette, `docs/palette.md` | ANSI black is now `#3c3836` (was grey `#928374`), yellow is `#d8a657` everywhere (`.Xresources` had orange). |
| fish | `fish_variables` removed from the repo | It's machine state that fish rewrites. Colors now in `conf.d/gruvbox-material.fish`. |
| Notifications | dunstrc rewritten for dunst 1.9, Gruvbox colors | The old file had deprecated options (`geometry`, `[shortcuts]`) and Arc theme colors. |

### Bugs fixed along the way

* i3: shutdown ran `systemctl shutdown` (not a command) → `systemctl poweroff`.
* `.gitconfig`: `[mergtool]` typo, so the mergetool settings were ignored.
* `.vimrc`: ruff path pointed into `~/miniconda3`.
* `.bashrc` / `.profile`: hardcoded `/home/elin`; failed if rustup was not installed.
* `fish_user_key_bindings.fish` sourced fzf outside the function, on every load.
* dunst `dmenu` option used invalid rofi flags.
* keyboard-daemon printed "Display daemon shutting down".

## Testing checklist for the overhaul

Install first: `polybar picom kitty rofi dunst xss-lock flameshot imagemagick ripgrep` (apt),
then the bundle (nvim, fzf, starship, uv...). Then `./copy_to_home.py`.

- [ ] `~/.config/i3/scripts/machine-profile.sh` prints `remote` on the work machine
- [ ] Log out/in: no i3 error bar; `~/.cache/i3-autostart.log` looks sane
- [ ] polybar at the bottom: workspaces, window title, disk/mem/cpu, clock, tray
- [ ] Click the clock (long date), CPU (opens btop)
- [ ] `Super+w` names a workspace; `Alt+<number>` still reaches it
- [ ] picom runs (tested before): GTK menus/tooltips have no black corners, and no shadows or fades
- [ ] `Alt+Return` opens kitty with fish, font and colors right
- [ ] `Super+...` bindings get through the remote desktop client at all?
- [ ] Caps lock acts as Ctrl over the remote desktop
- [ ] tmux: `Ctrl+a Space` menu
- [ ] `z <part of a dir name>` after cd'ing around a bit
- [ ] `Alt+d`, `Super+Space`, `Super+x` (power menu), `Super+e` (files) in rofi
- [ ] `Super+Escape` / system mode `l` locks; unlock works
- [ ] `notify-send test` looks Gruvbox; `Super+n` closes it
- [ ] tmux: colors, `Ctrl+a |`, `Ctrl+a R`
- [ ] fish: colors, `Ctrl+r` fzf history, `vim` expands to `nvim`
- [x] install-bundle.sh reports 28 parsers built; `:checkhealth nvim-treesitter` lists them; nvim doesn't try to download anything (VM, round 12)
- [ ] nvim: `:checkhealth`, open a Python file → diagnostics, `K`, `,f`, completion
- [ ] `pip install foo` outside a venv is refused
- [ ] `git config --file ~/.gitconfig.local user.email ...` then a test commit works
- [ ] `Alt+y` opens CopyQ; earlier copies are there; `Alt+x` opens the power menu
- [ ] Font sizes OK; `xrdb -query | grep dpi` shows 96; try 108 or 120 to compare
- [ ] GTK dark mode (open a file dialog, e.g. in Chrome)
- [ ] Caps lock as Ctrl in ThinLinc, and whether Windows' caps lock state gets out of sync
- [ ] `git mergetool` settings now apply (p4merge without prompts)

## Open questions

* **Move i3 to `Super`?** Alt is i3's modifier, which takes Alt combinations
  away from PyCharm (`Alt+Enter`, `Alt+1`...), fish (`Alt+c`, `Alt+e`) and
  nvim. Super is unused and close by. Muscle memory is the cost. One way to
  switch gradually:
  1. Change `set $mod Mod1` to `Mod4` and move today's `$super` bindings to
     `$mod+Shift`/`$mod+Ctrl` variants.
  2. During the transition, add Alt duplicates only for the most used
     bindings (focus, workspaces, terminal) and remove them after a few weeks.
  The big question is whether the remote desktop client passes Super combos
  through (`Win+L` never gets through on Windows). The client has a setting
  for sending system keys (Alt+Tab etc.) to the remote machine, but it caused
  problems with the mouse back button. With the Eclipse keymap the Alt
  conflicts are fewer than first thought, so staying on Alt is reasonable.
* **Caps lock over the remote desktop:** `keyboard-daemon.sh` remaps it on
  the Linux side, which may not work through the remote desktop. If it
  doesn't, remap on the Windows side instead (PowerToys Keyboard Manager,
  Caps Lock → Ctrl). The client then sends a real Ctrl, which works
  everywhere, including the remote desktop.

## Ideas, not done yet

* **vim-tmux-navigator**: `Ctrl+h/j/k/l` moves between nvim splits *and*
  tmux panes. Costs `Ctrl+l` (clear screen) in the shell.
* **Clipboard history**: CopyQ (apt) or greenclip, with a rofi binding.
* **eza** (`ls` with icons/git status). In apt for 24.04.
* **lazygit** in a tmux popup or nvim float.
* **autorandr** to save/restore monitor setups on the laptop, instead of
  the custom display daemon.
* polybar: a module that shows the current machine profile, or
  CPU temperature on the laptop.
* nvim plugins worth a look (popular, maintained):
  * **mini.nvim** modules: `mini.surround` (add/change quotes and brackets
    around text), `mini.ai` (more text objects), `mini.pairs` (auto-close brackets).
  * **diffview.nvim**: review all changes of a branch, file history, and a
    3-way merge view (could replace p4merge).
  * **flash.nvim**: jump anywhere on screen with 2-3 keystrokes.
  * **trouble.nvim**: nicer list for diagnostics/references/quickfix.
  * **oil.nvim**: edit directories like text (rename/move files by editing lines).
  * **nvim-dap + nvim-dap-python** (debugpy): debugger inside nvim.
  * **neotest + neotest-python**: run pytest from nvim, results in the gutter.
  * **todo-comments.nvim**: highlight and list TODO/FIXME.
  * **snacks.nvim**: folke's collection (lazygit float, notifications,
    indent guides, file picker...).
  * **LazyVim** (a whole distribution) is good to browse for ideas even if
    we don't use it.