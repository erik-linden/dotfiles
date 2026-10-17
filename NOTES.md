# Notes

Decisions, open questions and ideas for this setup. Newest first.

## Constraints

* All Ubuntu 24.04, and all of them supported:
  * Mostly: a machine **without internet**, used **over ThinLinc**, one
    screen, no wifi/bluetooth/battery. Internal apt and pip mirrors (they
    lag a bit and sometimes lack dependencies). Other files have to be
    copied in by hand.
  * Desktops **with internet**.
  * Laptops (earlier; the laptop parts are kept).
* So configs must not assume either way: nothing "offline only" in the
  configs themselves; docs/SETUP.md marks the offline-only steps.
* Configs should **degrade gracefully** when a program is missing.
* Development happens on Linux with git (a VM), so changes can be tested
  before they're committed.
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

### 2026-10 round 17: offline bundle and profile logic tested on the VM

* **Offline bundle, end to end**: fresh fetch (1.3 GB, nothing failed),
  then install-bundle.sh into an empty home folder with the network cut
  off (`unshare --map-current-user -n`). All tools installed, Rust 1.99
  linked into rustup, i3wsr built offline, Fiji/p4merge linked, 28
  parsers; 74 s, peak +1 GB RAM. nvim offline: all 13 plugins, treesitter
  highlighting, blink.cmp's prebuilt matcher, `:checkhealth` clean, a
  forced parser update downloads nothing. i3wsr accepts config.toml.
* **Update path** (same bundle installed again): existing rustup reused,
  one `Fiji.bak` and `nvim.bak` (no timestamped piles), everything rebuilt.
* The first Rust setup prints a page of `cargo:rerun-if-env-changed`
  lines once; harmless, not seen again.
* **Online path, straight from docs/SETUP.md** (section 5, `cargo install
  --locked i3wsr`, the Fiji and p4merge blocks, each as a fresh login
  shell in an empty home folder): all succeeded (49 s, 22 s, 77 s, 25 s),
  every tool is found through .profile, and `.bashrc`, `.profile` and the
  fish files are untouched. nvim's first start: 13 plugins and 28 parsers
  in 16 s, peak +0.9 GB RAM, no errors; blink.cmp downloads its matcher
  when it first loads. (starship's installer prints a harmless warning
  about elvish, a shell we don't use.)
* **Profile logic** with stand-ins for polybar/xrdb: detection (VM,
  ThinLinc, xrdp, physical, override file), polybar's modules per profile
  and monitor count, grayscale font smoothing only on remote. Not
  testable here: the laptop branch (needs a battery).
* Fixed: autostart.sh and polybar's launch.sh failed completely without
  `~/.cache` (they log there); they create it now. A misspelled profile in
  `~/.config/machine-profile` meant "remote" to polybar but "physical" to
  autostart.sh; machine-profile.sh now ignores unknown values (with a
  warning in the autostart log) and detects the profile instead.

### 2026-10 round 16: second review (design)

* tmux starts fish, or bash if fish isn't installed (like kitty).
* **Grayscale font smoothing over a remote desktop**: subpixel smoothing
  turns into colored fringes there (the picture is compressed).
  i3/scripts/load-xresources.sh loads `.Xresources` and sets
  `Xft.rgba: none` on the remote profile; autostart.sh and polybar's
  launch.sh both use it (either could otherwise put `rgb` back).
* polybar: `wm-restack = i3` removed (only logged a warning).
* Kept as is, on purpose: the § → ~ remap in keyboard-daemon.sh applies
  on any layout (on a US layout that key is the backtick, but no US
  keyboards are used); long i3wsr workspace names (see how it looks
  first); no tray on multi-monitor setups without a primary monitor.
* **nvim swap files back on** (the old .vimrc had them off), while kitty
  keeps closing windows without asking (handy for tmux, btop). Closing a
  kitty window running nvim used to lose unsaved changes; now the next
  open offers to recover them. Tested: a normal quit leaves no swap file,
  a killed nvim leaves one. They live in ~/.local/state/nvim/swap, not
  next to the files.
* **nvim is off the system clipboard** (was `unnamedplus`, from the old
  .vimrc): every yank and delete ended up in CopyQ's history. `,y`/`,p`
  copy to / paste from the system clipboard.
* nvim only installs parsers at startup if a C compiler (`cc`) is there
  too; without one, it failed again at every start. (Stock Ubuntu has no
  gcc; SETUP.md section 2 installs build-essential.)

### 2026-10 round 15: fixes from a review of the whole branch

* **Idle locking was on by accident**: X's screensaver starts after 10 idle
  minutes and xss-lock locked then. autostart.sh now runs `xset s off`;
  xss-lock still locks before suspend.
* lock.sh, when started by xss-lock before a suspend, releases xss-lock's
  sleep lock once the screen is locked (as xss-lock's own example does);
  before, the suspend waited for logind's timeout. Tested with a stand-in
  i3lock: released after 0.4 s instead of at unlock.
* i3wsr: the i3 config stops a running i3wsr before starting one. (The
  review thought `exec_always` also ran on reload and piled up copies;
  wrong: it only runs on restart, which ends the old i3wsr anyway. The
  pkill stays as a cheap safeguard. Also: an i3 *reload* doesn't restart
  polybar either; config changes reach it through its `--reload` flag or
  an i3 restart.)
* nvim's compiled spell file (`en.utf-8.add.spl`, binary) is no longer
  copied by copy_to_home.py/copy_to_repo.py (it crashed copy_to_home.py,
  which reads text) and is in .gitignore. nvim builds it from the `.add`
  word list when it's missing or older (options.lua). copy_to_home.py
  skips any other non-text file with a message instead of crashing, and
  again makes an existing file executable when the repo's copy is.
* The treesitter memory fix uses `HOST_CFLAGS` instead of `CFLAGS`:
  tree-sitter's build (Rust's cc crate) reads it, make and configure
  don't, so builds started from nvim's terminal keep their own flags.
* fetch-offline-bundle.sh hides tree-sitter from PATH while it runs nvim
  (otherwise nvim built parsers on the fetch machine and they ended up in
  the bundle), and deletes half-downloaded files (install-bundle.sh would
  have tried to unpack them). install-bundle.sh keeps one backup
  (`Fiji.bak`, `nvim.bak`) instead of a new timestamped one each time.
* Missing programs: kitty starts fish through a wrapper that falls back to
  bash (config.fish then loads kitty's shell integration itself); git's
  pager falls back to less without delta, `git add -p` to plain output, and
  `git lg`/`ll` to less without diff-highlight; `h` works without bat.
* bash's fzf now has the same settings as fish's (colors, ripgrep list).
* tmux uses named colors where the palette color is a terminal color.
* fish writes the pixi/uv completions to a file once (again after an
  update) instead of running both programs at every shell start.

### 2026-10 round 14: more in the offline bundle (Rust, i3wsr, Fiji, p4merge)

* **Rust offline**: rustup can't install toolchains without internet, so
  the bundle has Rust's standalone installer
  (`rust-<version>-x86_64-unknown-linux-gnu.tar.xz`, newest stable) and
  `rustup-init`. install-bundle.sh installs the toolchain
  into `~/.local/opt/rust`, rustup into `~/.cargo` (`--default-toolchain
  none --no-modify-path`, works offline) and links the two
  (`rustup toolchain link bundle`, `rustup default bundle`). Chosen over
  links in `~/.local/bin` without rustup, because then `cargo install`
  (→ `~/.cargo/bin`) would not be on PATH; this way online and offline
  machines look the same, and the existing `~/.cargo/env` lines do the PATH.
  `rustup update` can't update a linked toolchain: install a newer bundle.
  Only the components of rustup's default profile (rustc, cargo, std,
  docs, rustfmt, clippy) plus rust-analyzer are installed: 1.6 GB, most
  of it the docs; the rest of the installer would add 0.3 GB.
* **i3wsr** names workspaces after their windows (`3 kitty | chrome`),
  replacing manual renaming. No prebuilt binaries, so the fetch script
  downloads the newest release's source and `cargo vendor`s its
  dependencies (using the bundle's own cargo, no compiler needed there);
  install-bundle.sh builds it offline (`cargo install --offline --locked
  --path .`) into `~/.cargo/bin`, the same place as `cargo install i3wsr`.
  Tested offline (no network namespace): Rust + i3wsr install in about a
  minute; the whole install, parsers included, peaks at ~0.9 GB of RAM.
* i3 starts it with `exec_always` (skipped if i3wsr isn't installed).
  Tested in a nested i3 4.23: a *reload* doesn't run `exec_always` again
  and keeps the running i3wsr; a *restart* starts a new one and the old one
  exits by itself, so no `pkill` is needed. Config
  `~/.config/i3wsr/config.toml`: `" | "` between names, duplicates
  removed, short lowercase aliases for a few long classes (Chrome,
  PyCharm...); other windows show their class as it is (`XEyes`). No
  icons. polybar keeps `strip-wsnumbers = false`, so the number stays
  visible; the `workspace number N` bindings still reach renamed
  workspaces (tested).
* **Fiji** (`fiji-latest-linux64-jdk.zip`, the old `fiji-linux64.zip` URL
  is gone) and **p4merge** (`p4v.tgz`, version variable at the top of
  fetch-offline-bundle.sh, now r26.3) are in the bundle, installed into
  `~/.local/opt/Fiji` (the zip's folder is now `Fiji/`, no longer
  `Fiji.app/`; the launcher is `fiji-linux-x64`) and
  `~/.local/opt/p4merge`, with links. An existing Fiji folder is moved to
  a `.bak.<date>` folder, like nvim's data, since Fiji updates itself (and
  its plugins) in place. On its first start Fiji adds its own launcher
  entry and file types to `~/.local/share/applications` and `mime` (so
  rofi finds it); it uses the home folder from the user database, not
  `$HOME`. Both start (tested: `fiji --headless -eval`, `p4merge -V`).
* The bundle is about 1.3 GB now (Fiji 0.7 GB, Rust 0.2 GB, P4V 0.2 GB);
  each part stays optional: delete a file from the folder to skip it.

### 2026-10 round 13: review of the whole refresh (USER-NOTES.md)

* Windows-era workarounds removed: `copy_to_home.py` no longer makes
  scripts executable (git keeps the bit; a new file is copied with it).
  `HOME`/`DOTFILES` are public names, since copy_to_repo.py imports them.
* **"Work machine" is gone from the docs**: steps say "without internet"
  instead. docs/SETUP.md section 5 has both ways to install the tools apt
  lacks: each tool's own installer (with internet) or the offline bundle.
  The bundle is only for machines without internet: its parser sources
  would keep `:TSUpdate` from downloading newer parsers.
* Installers must not edit the shell config (the dotfiles already set
  PATH): `UV_NO_MODIFY_PATH=1`, `PIXI_NO_PATH_UPDATE=1`, rustup
  `--no-modify-path`. (pixi only looks for its own exact line, with the
  full path, so it would add a duplicate; uv adds its own env script;
  rustup does recognize our lines.) Tested: the documented online install
  leaves `.bashrc`, `.profile` and the fish files unchanged.
* The `-Wno-uninitialized` fix (round 12) moved into plugins/treesitter.lua,
  so it also applies to online installs and `:TSUpdate`, not only to
  install-bundle.sh. Online first start: plugins + 28 parsers, peak +0.6 GB.
* **Terminal programs use the terminal's colors** (named ANSI colors from
  kitty.conf) instead of hex values: fish (its defaults; the
  conf.d/gruvbox-material.fish file is gone), starship (no `[palettes]`),
  fzf (`--color=16`), bat and delta (`ansi` theme). Exceptions: delta's
  diff background tints, and tmux's status bar (bg1 isn't an ANSI color).
  Changing the theme now mostly means changing kitty.conf.
* Removed: terminator, i3status and the commented-out i3bar block, `.vimrc`
  (Neovim only), the JetBrains Toolbox (to be decided separately), the
  rename-workspace script and `Super+w` (workspaces should be named after
  their content; see Ideas), `Alt+u` (urgent window; collides with
  PyCharm's Run menu `Alt+U`), polybar's window title (i3's title bars show
  it) and VPN module, kitty's Ctrl+click for links (trying kitty's default:
  click opens), the `git mt` nvimdiff alias (p4merge stays), the Azure CLI
  and fstab sections, and the git PPA (24.04's git 2.43 is new enough).
* i3: matplotlib windows float (class `matplotlib`, both Qt and Tk).
* rofi: `Ctrl+h`/`Ctrl+l` switch tabs, next to `Ctrl+j`/`Ctrl+k` for the list.
* unclutter (hide the cursor while typing) on all machines.
* rofi: the `drun` and `keys` tabs and their `Super+Space`/`Super+k`
  bindings are gone; `Alt+d` (combi) lists apps and windows, without the
  mode prefix.
* kitty's update check is back to its default (round 3 had turned it
  off): only kitty's own builds check, so a hand-installed kitty on an
  online machine says when it's outdated; apt's build never checks and
  offline checks fail silently.
* delta replaces diff-highlight for word-level highlighting too (it marks
  changed words in `git diff`, `log -p` and `show`). Except under
  `--graph`: delta (also 0.20, the newest) can't read diffs with the graph's
  `| ` in front, so the graph aliases `lg`/`ll` get diff-highlight as their
  own pager (`[pager]` in .gitconfig; git allows a pager per alias).
* Docker setup fixed: it lacked the step that adds Docker's apt repository.

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
* **No window borders** in the first i3 login: i3 drops the border of
  windows that ask for no decorations (Motif hints). kitty did that because
  of `hide_window_decorations yes` (removed; on X11 that's all it does),
  Electron apps (Claude, Chrome, VS Code) do it themselves. Fixed with
  `for_window [all] border normal 5` in the i3 config.
* **US keyboard in i3** although GNOME used Swedish: GNOME has its own
  layout setting, i3 gets the system X default. Not fixed in the dotfiles
  (a machine setting, and over ThinLinc the client may decide);
  setting `XKBLAYOUT="se"` in `/etc/default/keyboard` is in docs/SETUP.md
  (`localectl set-x11-keymap` is not supported on Debian/Ubuntu).
* i3lock-color build packages: installed normally, exactly the list from
  its GitHub page, instead of `--mark-auto`. They clutter
  `apt-mark showmanual`, but an `autoremove` can't take away the runtime
  libraries the built binary needs. (Alternative considered: an `equivs`
  placeholder package depending on the libraries; more steps than it's worth.)
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
| Bar | i3bar + i3status → **polybar** | Shows workspace names, clickable modules, tray. In apt. (The window title in the middle and the old i3bar block were removed in round 13.) |
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

- [ ] `~/.config/i3/scripts/machine-profile.sh` prints `remote` on the ThinLinc machine
- [ ] Log out/in: no i3 error bar; `~/.cache/i3-autostart.log` looks sane
- [ ] polybar at the bottom: workspaces, disk/mem/cpu, clock, tray
- [ ] Click the clock (long date), CPU (opens btop)
- [ ] i3wsr names workspaces after their windows; `Alt+<number>` still reaches them; after an i3 restart only one i3wsr runs (`pgrep -a i3wsr`)
- [ ] picom runs (tested before): GTK menus/tooltips have no black corners, and no shadows or fades
- [ ] `Alt+Return` opens kitty with fish, font and colors right
- [ ] `Super+...` bindings get through the remote desktop client at all?
- [ ] Caps lock acts as Ctrl over the remote desktop
- [ ] tmux: `Ctrl+a Space` menu
- [ ] `z <part of a dir name>` after cd'ing around a bit
- [ ] `Alt+d`, `Super+x` (power menu), `Super+e` (files) in rofi
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