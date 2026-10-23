# Setting up a machine

Manual steps for Ubuntu 24.04 with i3. Follow the sections top to bottom,
skipping what doesn't apply. Steps that only apply to a machine **without
internet** (for example one that only reaches internal package mirrors) say so.

**Where software comes from, in order of preference:**

1. **apt**, if the Ubuntu version is new enough. Without internet, through
   the apt mirror.
2. **Tools that apt doesn't have, or has too old** (Neovim, fzf, starship,
   tree-sitter, uv, pixi, Rust, the font; also Fiji), section 5. With internet, each tool's own installer. Without
   internet, the **offline bundle**: one script downloads everything on a
   machine with internet, another installs it on the machine without.
   (Rust without internet comes from apt instead, section 5.)
3. **Manual steps**: everything else, described below.

**Where hand-installed programs go.** Everything not from apt is installed
in your home folder, without sudo:

1. If the program has **its own installer or documented place**, use that,
   so the paths match its documentation: pixi (`~/.pixi/bin`), uv
   (`~/.local/bin`), rustup (`~/.cargo`).
   The offline bundle uses the same places.
2. Otherwise, a **single file** (fzf, starship, tree-sitter, bazel) goes
   straight into `~/.local/bin`, which `.profile` puts on `PATH`,
3. and a **folder** (Neovim, Fiji) goes into `~/.local/opt/<name>`,
   with a link to its executable in `~/.local/bin`. Updating means replacing
   the folder; uninstalling means deleting the folder and the link.

The one exception is i3lock-color, which replaces the system's `i3lock`
(a lock screen needs the system-wide login/PAM setup).

**Without internet: packages missing from the apt mirror.** If a package,
or one of its dependencies, is missing from the mirror, download the `.deb`
files on an Ubuntu 24.04 machine with internet and copy them over.
`-o Dir::Cache::archives="$PWD"` makes apt save the downloaded files in the
current folder instead of its own cache (`/var/cache/apt/archives`):

```bash
mkdir debs && cd debs
sudo apt-get install --download-only -o Dir::Cache::archives="$PWD" <packages>
# on the machine without internet:
sudo apt install ./*.deb
```

---

## 1. Without internet: certificate and package mirrors

Do this first; everything that downloads needs it.

**Company CA certificate**
```bash
# wget --no-check-certificate https://<certificate-url>/<company-ca>.crt
sudo cp <company-ca>.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```
Browsers may keep their own list of certificates; if a site still shows a
certificate error, import the certificate in the browser's settings too.

**Package mirrors.** The config files can be written before uv/pixi are
installed. Uncomment the lines and fill in the real URLs; they are kept out
of this repo on purpose.

`~/.config/uv/uv.toml`
```toml
# Use the system certificate store (with the company CA).
# uv versions before ~0.9 call this `native-tls = true` instead.
system-certs = true

# [[index]]
# url = "https://<pypi-mirror>/simple"
# default = true

# uv downloads Python builds from GitHub. Without access, either use the
# system Python:
#   python-downloads = "never"
# or a mirror of https://github.com/astral-sh/python-build-standalone/releases:
#   python-install-mirror = "https://<python-build-mirror>"
```

`~/.pixi/config.toml`
```toml
# [mirrors]
# "https://conda.anaconda.org/conda-forge" = ["https://<conda-forge-mirror>"]

# [pypi-config]
# index-url = "https://<pypi-mirror>/simple"
```

pip itself (for the rare cases where pip is used directly):

```bash
# sudo pip config --global set global.index-url https://<pypi-mirror>/simple
# sudo pip config --global set global.trusted-host <pypi-mirror-host>
```

`~/.cargo/config.toml` (Rust's crates; the mirror's own docs give the URL
and whether it is a `sparse+https://` registry)
```toml
# [source.crates-io]
# replace-with = "mirror"
#
# [source.mirror]
# registry = "sparse+https://<crates-mirror>/"
```

If uv or pixi still complain about certificates, point them at the system store:
`set -Ux SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt`

## 2. Packages from apt

The desktop itself (i3, polybar...) is installed in section 6.

```bash
# Terminal tools
#   bat: colored file viewer, also for --help and man pages, btop: system
#   monitor, curl: downloads, expect: provides `unbuffer`, fd-find: fast
#   `find` (command `fdfind`, used by fzf-lua), fish: the shell, git-delta:
#   nicer git diffs, jq: query and pretty-print JSON, kitty: terminal,
#   ranger: file manager, ripgrep: fast grep (`rg`, used by fzf and nvim),
#   tmux: terminal multiplexer, tree: directory tree, xclip: clipboard for
#   tmux, zoxide: `z` to jump to directories
sudo apt install bat btop curl expect fd-find fish git-delta jq kitty ranger ripgrep tmux tree xclip zoxide

# Ubuntu calls bat `batcat` (the name was taken); make `bat` work too
mkdir -p ~/.local/bin && ln -sf /usr/bin/batcat ~/.local/bin/bat

# Building C/C++ code: build-essential (gcc, g++, make), autoconf and
# pkg-config (many projects' build scripts, e.g. i3lock-color), clang, cmake,
# ninja. Also needed to build Neovim's treesitter parsers.
sudo apt install build-essential autoconf pkg-config clang cmake ninja-build default-jdk

# Applications
#   kdiff3: git's merge tool (3-way: base, yours, theirs, result below),
#   meld: git's directory diffs (`git dt`)
sudo apt install ffmpeg gimp inkscape kdiff3 keepass2 krita libreoffice meld \
    pinta qdirstat shutter v4l-utils vlc font-manager gnome-tweaks

# Optional, only if you need them
#   openssh-server: ssh *into* this machine (not needed to ssh out)
#   cifs-utils: mount Windows/SMB network shares, e.g. in /etc/fstab
#   smbclient: browse SMB shares from the command line
sudo apt install openssh-server cifs-utils smbclient

# Large (several GB). If the install seems stuck, it is usually waiting on a
# hidden prompt: hold down Enter.
sudo apt install texlive-full
```

`kitty` comes from apt (0.32): the dotfiles need nothing newer, and apt
keeps it updated.

## 3. Git

Ubuntu 24.04's git (2.43) is new enough for everything in `.gitconfig`.

```bash
sudo apt install git git-lfs
```

The email is not in the repo. Set it per machine (goes to `~/.gitconfig.local`):

```bash
git config --file ~/.gitconfig.local user.email <your email>
```

Diffs are shown with [delta](https://github.com/dandavison/delta) (apt
package `git-delta`, configured in `.gitconfig`). Inside the pager: `n`/`N`
jumps between files, `q` quits. Side by side for one command:
`git -c delta.side-by-side=true diff`. If delta is not installed, git
fails to show diffs; then install it or remove the `pager` lines in `.gitconfig`.

**SSH keys** from another machine:
```bash
rsync -avh <old-machine>:.ssh/id_rsa* ~/.ssh/
# If this machine is a server:
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

## 4. Dotfiles

```bash
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/erik-linden/dotfiles.git   # without internet: copy the folder over
cd dotfiles
./copy_to_home.py --dry-run   # see what would change
./copy_to_home.py
```

Run it again after every `git pull`. To go the other way, after changing
files on the machine, run `./copy_to_repo.py` and check `git diff`.

## 5. Tools that apt doesn't have, or has too old

Neovim 0.11+ (apt: 0.9), fzf 0.48+ (apt: 0.44; fish needs
0.48), starship, tree-sitter (builds Neovim's parsers), uv, pixi, Rust and
the JetBrains Mono Nerd Font. All go into your home folder, no sudo. (Fiji is
in section 10; without internet, the bundle below has it too.) The dotfiles already put them on `PATH`, so the installers are told
not to edit `.bashrc`, `.profile` or the fish config.

### With internet

Each tool's own installer or release download. Run the same lines again to
update (uv, pixi and Rust can also update themselves: `uv self update`,
`pixi self-update`, `rustup update`).

```bash
mkdir -p ~/.local/bin ~/.local/opt

# Neovim
rm -rf ~/.local/opt/nvim && mkdir ~/.local/opt/nvim
curl -fL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    | tar xz --strip-components=1 -C ~/.local/opt/nvim
ln -sf ~/.local/opt/nvim/bin/nvim ~/.local/bin/nvim

# fzf (the release file's name has the version in it, so ask GitHub for it)
curl -fL "$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest \
    | grep -o 'https://[^"]*linux_amd64\.tar\.gz')" | tar xz -C ~/.local/bin fzf

# starship
curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin

# tree-sitter
curl -fL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
    | gunzip > ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter

# uv, pixi and Rust (rustup), without letting them edit the shell config
curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
curl -fsSL https://pixi.sh/install.sh | PIXI_NO_PATH_UPDATE=1 sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Font
mkdir -p ~/.local/share/fonts/JetBrainsMono
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
    | tar xJ -C ~/.local/share/fonts/JetBrainsMono
fc-cache -f
```

Neovim installs its plugins on the first start (the versions in
`lazy-lock.json`), then downloads and builds the treesitter parsers in the
background (needs `tree-sitter` and a C compiler). Later: `:Lazy update`
updates the plugins (then `./copy_to_repo.py` to save the new
`lazy-lock.json`), `:TSUpdate` the parsers.

### Without internet: the offline bundle

On a Linux x86_64 machine **with internet** (with the dotfiles repo cloned):

```bash
scripts/fetch-offline-bundle.sh ~/dotfiles-bundle
```

This downloads Neovim, fzf, starship, tree-sitter, uv, pixi, the font,
Fiji, all Neovim plugins (`nvim-data.tar.gz`), and the source code of the
treesitter parsers (`parser-sources.tar.gz`). It needs no compiler, and
works on any Linux. It is about 0.85 GB, most of it Fiji; delete the files
you don't want from the folder, each part is optional. Copy
`~/dotfiles-bundle` to the machine without internet, then:

```bash
~/dotfiles-bundle/install-bundle.sh
```

Everything goes to the same places as the installers above. The treesitter
parsers are compiled here, so they match this machine: that needs a C
compiler (section 2) and the Neovim config already copied (section 4). If
that step fails, Neovim still works with simpler highlighting; fix it and
run the script again. Neovim then builds parsers from these sources instead
of downloading them, also for `:TSUpdate`. To update, run both scripts
again with a new bundle.

Don't use the bundle on a machine with internet: its parser sources would
keep `:TSUpdate` from downloading newer parsers. (To undo that: delete
`~/.local/share/nvim/parser-sources`.)

**Rust without internet: from apt.** rustup can't download toolchains, but
Ubuntu packages recent Rust versions (`rustc-1.91`, `cargo-1.91`...),
which come through the apt mirror. Install the newest one there is
(`apt-cache search --names-only '^rustc-1\.'`), with the standard library's
source code, which RustRover needs:

```bash
sudo apt install rust-1.91-all rust-1.91-src
# The commands are called cargo-1.91 etc.; link the plain names
for f in /usr/lib/rust-1.91/bin/*; do ln -sf "$f" ~/.local/bin/; done
```

In RustRover, set the toolchain to `/usr/lib/rust-1.91/bin` (Settings →
Rust); it finds the library source from there. For a newer version later:
install the new packages, run the `ln` line with the new number, remove the
old ones. Crates (dependencies) need the crates mirror from section 1; for
a project without one, run `cargo vendor` on a machine with internet and
follow what it prints. Programs from `cargo install` go to `~/.cargo/bin`,
which the dotfiles put on `PATH` when it exists.

### Afterwards

Log out and in again so that `~/.local/bin` is on `PATH`. Check the font
with `fc-list | grep -i jetbrains`.

## 6. Desktop: i3, polybar, picom, rofi, dunst, lock screen

```bash
# Window manager, bar, compositor (so GTK transparency isn't drawn black;
# no effects), launcher, notifications, python3-i3ipc (for the script that
# names workspaces after their windows), qt5ct (dark colors for Qt apps)
sudo apt install i3 polybar picom rofi dunst python3-i3ipc qt5ct
# Lock screen: i3lock, xss-lock (locks on suspend/idle), imagemagick (blurred screenshot)
sudo apt install i3lock xss-lock imagemagick
# dex: runs XDG autostart entries, feh: wallpaper, flameshot: screenshots,
# numlockx: numlock on at login, arandr: monitor setup GUI,
# pavucontrol: volume mixer (right-click the volume in the bar),
# copyq: clipboard history (Alt+y), unclutter-xfixes: hides the mouse
# cursor while typing
sudo apt install dex feh flameshot numlockx arandr pavucontrol copyq unclutter-xfixes

# Laptop only: bluetooth, brightness keys/lid/suspend
sudo apt install blueman xfce4-power-manager
```

`xfce4-notifyd` competes with dunst for notifications. If notifications
look wrong, run `sudo apt remove xfce4-notifyd`.

**Machine profile.** `~/.config/i3/scripts/machine-profile.sh` detects
whether this is a `laptop`, a `desktop` or a `remote` (VM / remote
desktop) session. The autostart script (`scripts/autostart.sh`) and the bar use it:

| Profile | Extra programs | Bar modules |
|---------|----------------|-------------|
| laptop  | nm-applet, blueman, xfce4-power-manager, display daemon | wifi, ethernet, battery, volume |
| desktop | nm-applet, display daemon | ethernet, volume |
| remote  | (picom without GPU/vsync) | disk, memory, CPU, clock only |

Check with `~/.config/i3/scripts/machine-profile.sh`. If detection gets it
wrong, force a profile: `echo remote > ~/.config/machine-profile`.

Logs: `~/.cache/i3-autostart.log`, `~/.cache/polybar-*.log`.

**Wallpaper:** put it in `~/Pictures/wallpaper.jpg`.

**Dark mode for GTK apps** (file dialogs, pavucontrol, Nautilus...). No
theme to install; Ubuntu ships dark variants. The settings daemon started
by `autostart.sh` passes this on to the apps:

```bash
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Yaru-dark
```

Restart the apps afterwards. (A full Gruvbox GTK theme exists too, but it
is a manual download; not worth it for now.) Newer GTK4 apps (Nautilus,
GNOME Text Editor...) read the dark mode setting through
xdg-desktop-portal, which the dotfiles set up for i3
(`~/.config/xdg-desktop-portal/i3-portals.conf`). If one still starts
light right after copying that file, run
`systemctl --user restart xdg-desktop-portal` (or log in again).

**Dark mode for Qt apps** (kdiff3, CopyQ, flameshot...). Qt doesn't follow
the GTK setting outside GNOME, so `.profile` points Qt apps at qt5ct
(`QT_QPA_PLATFORMTHEME=qt5ct`, if qt5ct is installed). Its settings in
`~/.config/qt5ct/` pick the Fusion style and a Gruvbox palette; they apply
from the next login. (The `qt5ct` program can change them, but rewrites
the file; then run `./copy_to_repo.py`.)

kdiff3 paints its text panes in its own colors, kept in
`~/.config/kdiff3rc` together with its window size, so they aren't in the
repo. Set them once (colors from docs/palette.md, as r,g,b):

```bash
set_color() { kwriteconfig5 --file kdiff3rc --group "KDiff3 Options" --key "$1" "$2"; }
set_color FgColor                   212,190,152   # fg0
set_color BgColor                   29,32,33      # bg0
set_color DiffBgColor               40,40,40      # bg1: lines that differ
set_color ColorA                    125,174,163   # blue: text from A (base)
set_color ColorB                    169,182,101   # green: text from B (yours)
set_color ColorC                    211,134,155   # purple: text from C (theirs)
set_color ColorForConflict          234,105,98    # red
set_color CurrentRangeBgColor       60,56,54      # bg3: the selected difference
set_color CurrentRangeDiffBgColor   71,60,41      # bg_visual_yellow: its changed lines
set_color ManualAlignmentRangeColor 80,73,69      # bg5
```

**Keyboard layout.** GNOME keeps its own layout setting, but i3 gets the
system's X default (`us` if Ubuntu was installed with an English keyboard).
Set the system default to Swedish once; this also covers the login screen.
`keyboard-daemon.sh` adds caps lock as Ctrl and § as ~ on top of it:

```bash
# (localectl can't do this on Ubuntu/Debian; the setting lives in this file)
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="se"/' /etc/default/keyboard
```

Takes effect after a reboot. Check with `setxkbmap -query`. Over a remote
desktop, the client's layout may decide instead.

**Font size.** All of i3, polybar, rofi, dunst and kitty scale with
`Xft.dpi` in `~/.Xresources` (96 = 100%). The sizes in the individual
configs only set them relative to each other: i3 and the bar 9, terminal
and notifications 10, rofi 11. GTK apps follow gnome-tweaks →
Fonts → Scaling Factor instead. In gnome-tweaks, also set Monospace Text
to *JetBrainsMono Nerd Font Regular 10* and Antialiasing to Subpixel (RGB),
or Standard (grayscale) over a remote desktop, where subpixel colors fringe.
(i3, polybar, rofi and dunst switch to grayscale on their own there.)

**CopyQ** shows a tray icon in the bar; right-click it for settings, e.g.
the history size (default 200) or a dark theme (File → Preferences →
Appearance).

**unclutter** hides the mouse cursor while typing. It starts with the X
session; set `EXTRA_OPTS="-idle 1 -root --ignore-scrolling"` in
`/etc/default/unclutter`.

**Workspace names** come from their windows, e.g. `3 vim init.lua |
firefox`: `~/.config/i3/scripts/workspace-names.py`, started by the i3
config, renames them as windows open, close or change title. It needs
`python3-i3ipc` (installed above). The naming rules are at the top of the
script.

**Power settings (laptop):** run `xfce4-power-manager-settings`. Disable the
screen turning off and enable "Handle screen brightness keys".

### Optional: nicer lock screen (i3lock-color)

`lock.sh` works with plain `i3lock`, which gives a pixelated screenshot.
With [i3lock-color](https://github.com/Raymo111/i3lock-color) you get a
blurred screen, a clock and a colored ring. It has to be built from source
(build tools from section 2, plus these libraries):

```bash
sudo apt install libpam0g-dev libcairo2-dev libfontconfig1-dev \
    libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
    libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev \
    libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev
git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
sudo apt remove i3lock
./install-i3lock-color.sh
```

## 7. Neovim

Installed in section 5. Check everything with `:checkhealth` inside nvim;
`:Lazy` shows the plugins. The language servers for Python are installed
in section 8.

## 8. Python: uv and pixi

* **uv** for Python projects, virtual environments and command line tools.
* **pixi** for projects that need conda-forge packages (CUDA, compiled libraries).
* **pip** refuses to install outside a virtual environment (`~/.config/pip/pip.conf`).
  Override once with `PIP_REQUIRE_VIRTUALENV=0 pip install ...`.

Both are installed in section 5 (without internet, their mirrors are set up
in section 1).

Language servers for Neovim (from PyPI, so they also work through a pip mirror):

```bash
uv tool install ruff
uv tool install basedpyright
```

A global IPython with the usual scientific packages, for quick scratch work:

```bash
uv tool install ipython --with numpy --with scipy --with matplotlib \
    --with pandas --with scikit-learn --with sympy --with imageio --with rich
```

## 9. Chrome

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
```

Chrome keeps saved passwords in the GNOME keyring (`--password-store=gnome-libsecret`
in the i3 config). So that Chrome uses the keyring however it is started
(e.g. from rofi), make a local copy of its launcher with the same flag:

```bash
mkdir -p ~/.local/share/applications
sed 's|^Exec=/usr/bin/google-chrome-stable|Exec=/usr/bin/google-chrome-stable --password-store=gnome-libsecret|' \
    /usr/share/applications/google-chrome.desktop > ~/.local/share/applications/google-chrome.desktop
```

**The keyring password should be your login password**: then logging in
unlocks it and there is never a separate prompt. If you do get a "keyring"
password prompt, it is usually the *old* login password (the keyring
doesn't follow password changes). Fix it once: open "Passwords and Keys"
(`seahorse`), right-click the **Login** keyring → Change Password, enter
the old password, then the current login password.

## 10. Other software

**NVIDIA / CUDA** (https://docs.nvidia.com/cuda/cuda-installation-guide-linux/).
If CUDA is only needed by Python projects, pixi installs the CUDA libraries
per project, and the system only needs the driver (`sudo ubuntu-drivers install`).
For a system-wide CUDA toolkit:
```bash
sudo apt remove --purge 'nvidia*'
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo apt install ./cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install cuda
rm cuda-keyring_1.1-1_all.deb
```

**Bazel** via [bazelisk](https://github.com/bazelbuild/bazelisk), the
officially recommended launcher: installed as `bazel`, it downloads and
runs the Bazel version each project asks for (`.bazelversion`).
```bash
curl -fL -o ~/.local/bin/bazel \
    https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64
chmod +x ~/.local/bin/bazel
```
Without internet: copy the binary over the same way. bazelisk then also
needs the Bazel releases themselves, either from a mirror
(`export BAZELISK_BASE_URL=https://<bazel-mirror>`) or by copying
`~/.cache/bazelisk` from a machine where the project has built once.

**Docker** (https://docs.docker.com/engine/install/ubuntu/). Ubuntu's own
packages are older, so add Docker's apt repository first. Without internet,
this needs a mirror of that repository.
```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Run docker without sudo (https://docs.docker.com/engine/install/linux-postinstall/).
# The package creates the docker group. Log out and in for this to apply.
sudo usermod -aG docker $USER
# after logging in again:
docker run hello-world
```

**Fiji** (updates itself inside its folder, so it must be in your home).
Without internet it is in the offline bundle (section 5).
```bash
mkdir -p ~/.local/opt && cd ~/.local/opt
wget https://downloads.imagej.net/fiji/latest/fiji-latest-linux64-jdk.zip
unzip fiji-latest-linux64-jdk.zip    # creates Fiji/
rm fiji-latest-linux64-jdk.zip
ln -sf ~/.local/opt/Fiji/fiji-linux-x64 ~/.local/bin/fiji
```
(Older Fiji releases unpacked to `Fiji.app/` with an `ImageJ-linux64`
launcher; delete such a folder and its link before installing the new one.)
