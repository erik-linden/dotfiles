# Key bindings

A reminder of the keys that can't be discovered from the programs
themselves. Things you can find by looking (rofi's mode tabs, menus,
which-key popups, `?` help screens) are left out; where to look is noted
instead.

## Windows: the same keys in i3, tmux and nvim

Same letter, different prefix: **`Alt`** in i3, **`Ctrl+a`** in tmux,
**`Ctrl+w`** in nvim.

| Action | i3 | tmux | nvim |
|---|---|---|---|
| New window/pane **beside** | `Alt+i` | `Ctrl+a i` | `Ctrl+w i` (`:vsplit`) |
| New window/pane **below** | `Alt+n` | `Ctrl+a n` | `Ctrl+w n` (`:split`) |
| Focus left/down/up/right | `Alt+h/j/k/l` | `Ctrl+a h/j/k/l` | `Ctrl+w h/j/k/l` or `Ctrl+h/j/k/l` |
| Move left/down/up/right | `Alt+Shift+h/j/k/l` | `Ctrl+a Shift+h/j/k/l` | `Ctrl+w Shift+h/j/k/l` |
| Close | `Alt+q` | `Ctrl+a q` | `Ctrl+w q` |
| Fullscreen / zoom | `Alt+f` | `Ctrl+a f` | `Ctrl+w o` (close the others) |
| Resize mode | `Alt+r`, then `h/j/k/l`, `Esc` | `Ctrl+a r`, then `h/j/k/l`, `Esc` | `Ctrl+w < > + -` |

In i3, `Alt+i`/`Alt+n` decide where the *next* window goes. In tmux and nvim
they split right away. tmux also still takes `|` and `-`.

## i3

The i3 config is the only place to discover these.

| Keys | Action |
|---|---|
| `Alt+Return` / `Alt+d` | Terminal / rofi (apps + windows; other modes are tabs in rofi) |
| `Alt+Shift+h/j/k/l` | Move window |
| `Alt+w` / `Alt+e` / `Alt+s` | Tabbed / toggle split / stacked |
| `Alt+a` / `Alt+z` | Focus parent / child (to move or tab a whole group) |
| `Alt+Space` / `Alt+Shift+Space` | Focus floating↔tiling / toggle floating |
| `Alt+1..0` / `Alt+Shift+1..0` | Go to / move window to workspace |
| `Alt+p` / `Alt+Shift+p` | Move workspace to the other monitor / arandr |
| `Alt+Ctrl+Shift+l` | System menu: lock, logout, suspend, reboot, shutdown |
| `Alt+Ctrl+Shift+c` / `r` / `e` | Reload config / restart i3 / exit |
| `Alt+Shift+-` / `Alt+-` | **Scratchpad**: hide a window / bring it back (e.g. a notes terminal) |
| `Alt+Shift+w` | Chrome |
| `Alt+Shift+Return` | Toggle touchpad |
| `Alt+x` or `Super+x` | **Power menu**: lock, logout, suspend, reboot, shutdown |
| `Alt+y` | **Clipboard history** (CopyQ): pick an earlier copy, `Enter` puts it back on the clipboard |
| `Super+Escape` | Lock |
| `Super+n` / `Super+Shift+n` / `Super+m` | Close notification / close all / show the last one again |
| `Super+.` | Notification actions (e.g. "open") |
| `Print` | Screenshot of an area (flameshot) |
| `Super+p` | Cycle displays: single → next → mirror → extend (laptop) |

The bar: click the clock for the long date, the CPU/memory for btop, right-click the volume for the mixer.

## rofi

The modes (apps, windows, files, ssh, power...) are tabs along the bottom.

| Keys | Action |
|---|---|
| `Ctrl+h` / `Ctrl+l` | Previous / next tab (also `Ctrl+Tab` / `Ctrl+Shift+Tab`) |
| `Ctrl+j` / `Ctrl+k` | Down / up in the list (also the arrow keys) |

## tmux (prefix `Ctrl+a`)

`Ctrl+a Space` opens a **menu** with the common actions; `Ctrl+a ?` lists all
keys. The mouse works: click to focus, drag borders, scroll, right-click.
Besides the window keys above:

| Keys | Action |
|---|---|
| `c` / `1..9` / `Tab` (in the menu) | New window / go to window / next window |
| `[` | **Scroll and copy mode**: `/` search, `v` select, `y` copy, `Esc` leave |
| `d` | Detach (tmux keeps running, `tmux attach` to come back) |
| `Ctrl+a Ctrl+a` | Send `Ctrl+a` (start of line in the shell) |

## nvim (leader `,`)

Press `,` and wait: a popup lists all leader mappings (`,s` search, `,g` git).

| Keys | Action |
|---|---|
| `jk` | Escape |
| `,w` | Save |
| `,y` / `,p` | **Copy to / paste from the system clipboard** (`,yy` line, `,y` + selection or motion; `,P` pastes before). Plain `y`/`d`/`p` stay inside nvim |
| `,f` | Format (ruff: fix, sort imports, format) |
| `,Enter`, `Esc` | Clear search highlight |
| `Space` / `Ctrl+Space` | Search forward / backward |
| `0` / `+` | First non-blank / end of line |
| `Ctrl+p` / `Ctrl+n` | Find file / file tree (`g?` in the tree for help) |
| `,sg` | **Grep the whole project** |
| `,s.` | Reopen the last search |
| `F3` or `gd` / `F4` or `K` | Go to definition / documentation |
| `grr` / `grn` / `gra` | **References / rename / code action** (quick fixes) |
| `]d` / `[d`, `,e` | Next / previous problem, show its message |
| `]c` / `[c`, `,gp` | Next / previous git change, preview it |
| `gcc` / `gc` | Comment line / selection |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward (e.g. after go to definition) |
| Completion | `Tab`/`Shift+Tab` to pick, `Enter` to accept |

**The ones that always need looking up:**

| Keys | Action |
|---|---|
| `:%s/old/new/gc` | **Replace in the file, confirming each one**: `y` yes, `n` no, `a` all the rest, `q` stop, `l` this one and stop. The result is previewed while typing |
| `*` then `:%s//new/gc` | Same, for the word under the cursor (an empty pattern reuses the last search) |
| `:grep old`, then `:cdo s/old/new/gc \| update` | **Replace in the whole project**: find all hits (ripgrep, skips gitignored files), then replace in each one with confirmation and save. `:copen` shows the hit list |
| `]s` / `[s` | Next / previous spelling mistake |
| `z=` | Spelling suggestions for the word under the cursor (type the number) |
| `zg` / `zug` | Add the word to the dictionary / undo that (the words are saved in `~/.config/nvim/spell/`, part of the dotfiles) |
| `gqip` / `gqq` / `gq` (selection) | **Hard-wrap text**: paragraph / line / selection. `gw` instead of `gq` keeps the cursor where it is |
| `:set tw=80` | Width for `gq` (Neovim's default: 79 columns, or 72 in git commit messages) |

## fish

| Keys | Action |
|---|---|
| `Tab` | Complete (`Tab` again for a menu) |
| `Up` | History search for what's typed so far |
| `→` or `Ctrl+f` | Accept the grey suggestion |
| `Ctrl+r` / `Ctrl+p` | Fuzzy find in history / a file path (like `Ctrl+p` in nvim; `Ctrl+t` works too) |
| `Alt+c` | **Fuzzy cd** into a subdirectory |
| `Alt+v` | **Edit the command line in nvim** (for long commands; fish's `Alt+e` is taken by i3) |
| `jk` | Normal (vi) mode |
| `z <part of name>` / `zi` | Jump to a frequently used directory (zoxide) / pick one |
| `rcd` | ranger, and stay in its directory on quit |
| `h <command>` | **The command's `--help` in color**, paged (e.g. `h docker run`; fish's own `help` is its docs) |
| `bat <file>` | Show a file with syntax highlighting (`q` quits) |
| `cmd --color=always \| less`, `unbuffer cmd \| less` | Keep colors when piping into `less` |

## kitty

| Keys | Action |
|---|---|
| `Ctrl+Shift+c` / `v` | Copy / paste. In nvim (which takes the mouse), hold `Shift` while dragging to select for `Ctrl+Shift+c`, or use `,y` |
| `Ctrl+Shift+=` / `-` / `Backspace` | Font bigger / smaller / reset |
| `Ctrl+Shift+h` | **Whole scrollback in a pager** (search with `/`) |
| `Ctrl+Shift+p`, then `f` | **Pick a path on screen** and insert it (`w` word, `l` line) |
| `Ctrl+Shift+e` | Pick a URL on screen and open it |
| Click | Open a link (click and drag selects) |

## ranger

`?` shows help, `:` gives a command line with tab completion. Not obvious:

| Keys | Action |
|---|---|
| `Space` | Select (then `yy` copy / `dd` cut / `dD` delete act on all selected) |
| `pp` | Paste |
| `cw` / `a` | Rename / rename before the extension |
| `r` | Open with... |
| `zh` | Show hidden files |
| `S` | Shell in this directory (`exit` to return) |
| `m<key>` / `` `<key> `` | Set / jump to bookmark |
| `yp` | Copy the file's path |

## Known conflicts

* **`Alt` belongs to i3.** PyCharm's Eclipse keymap uses `Alt+Shift+<letter>`;
  i3 takes `Alt+Shift+h/j/k/l/w/p/Space` (Eclipse `Alt+Shift+L` = extract
  local variable). **Don't add new `Alt+Shift+<letter>` bindings to i3.**
* **`Ctrl+a`** is tmux's prefix, so "start of line" in the shell is
  `Ctrl+a Ctrl+a` (or `Home`) inside tmux.
* **ThinLinc** only sends `Super` (and `Alt+Tab`) to Linux in full screen
  mode, so the `Super` bindings are a bonus. Everything used daily has an
  `Alt` binding or is reachable through `Alt+d` / `Alt+x`. F8 opens the
  ThinLinc client menu, with a full screen toggle.
