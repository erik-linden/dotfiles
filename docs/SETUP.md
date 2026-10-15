# Setting up a machine

Manual steps for Ubuntu 24.04 with i3. Follow the sections top to bottom,
skipping what doesn't apply.

**Where software comes from, in order of preference:**

1. **apt**: if the Ubuntu version is new enough. On the work machine this goes
   through the internal apt mirror.
2. **The offline bundle**: tools where apt is too old or missing (Neovim,
   kitty, fzf, starship, tree-sitter, uv, pixi, the font). One script downloads
   everything on a machine with internet, and another installs it into
   `~/.local` without sudo. Online machines run both scripts on the same machine.
3. **Manual steps**: everything else, described below.

**Where hand-installed programs go.** Everything not from apt is installed
in your home folder, without sudo:

1. If the program has **its own installer or documented place**, use that,
   so the paths match its documentation: kitty (`~/.local/kitty.app`), pixi
   (`~/.pixi/bin`), uv (`~/.local/bin`), rustup (`~/.cargo`), the JetBrains
   Toolbox (`~/.local/share/JetBrains`). The offline bundle uses the same places.
2. Otherwise, a **single file** (fzf, starship, tree-sitter, bazel) goes
   straight into `~/.local/bin`, which `.profile` puts on `PATH`,
3. and a **folder** (Neovim, Fiji, p4merge) goes into `~/.local/opt/<name>`,
   with a link to its executable in `~/.local/bin`. Updating means replacing
   the folder; uninstalling means deleting the folder and the link.

The one exception is i3lock-color, which replaces the system's `i3lock`
(a lock screen needs the system-wide login/PAM setup).

**Offline machines:** if a package is missing from the apt mirror, or one of
its dependencies is, download the `.deb` files on an Ubuntu 24.04 machine with
internet and copy them over:

```bash
mkdir debs && cd debs
sudo apt-get install --download-only -o Dir::Cache::archives="$PWD" <packages>
# on the offline machine:
sudo apt install ./*.deb
```

---

## 1. Work machine: certificate and package mirrors

Do this first on the work machine; everything that downloads needs it.

**Company CA certificate**
```bash
# wget --no-check-certificate https://<certificate-url>/<company-ca>.crt
sudo cp <company-ca>.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```
Chrome: Settings → Privacy and security → Security → Manage certificates →
Authorities → Import.

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

If uv or pixi still complain about certificates, point them at the system store:
`set -Ux SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt`

**Azure CLI**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## 2. Storage (fstab)

```bash
mkdir ~/storage
sudo blkid                 # find the UUID of the partition (not the drive)
sudoedit /etc/fstab        # add a line for the new drive
sudo mount ~/storage
```

## 3. Packages from apt

The desktop itself (i3, polybar...) is installed in section 8.

```bash
# Terminal tools
#   bat: colored file viewer, also for --help and man pages, btop: system
#   monitor, fd-find: fast `find` (command `fdfind`, used by fzf-lua),
#   git-delta: nicer git diffs, ranger: file manager, ripgrep: fast grep
#   (`rg`, used by fzf and nvim), xclip: clipboard for tmux,
#   zoxide: `z` to jump to directories, expect: provides `unbuffer`
sudo apt install bat btop curl expect fd-find git-delta kitty ranger ripgrep tmux tree xclip zoxide

# Ubuntu calls bat `batcat` (the name was taken); make `bat` work too
mkdir -p ~/.local/bin && ln -sf /usr/bin/batcat ~/.local/bin/bat

# Building C/C++ code (build-essential: gcc/make, also needed to build
# Neovim's treesitter parsers from the offline bundle)
sudo apt install build-essential clang cmake ninja-build default-jdk

# Applications
sudo apt install ffmpeg gimp inkscape keepass2 krita libreoffice meld pinta \
    qdirstat shutter v4l-utils vlc font-manager gnome-tweaks

# Optional, only if you need them
#   openssh-server: ssh *into* this machine (not needed to ssh out)
#   cifs-utils: mount Windows/SMB network shares, e.g. in /etc/fstab
#   smbclient: browse SMB shares from the command line
sudo apt install openssh-server cifs-utils smbclient

# Large (several GB). If the install seems stuck, it is usually waiting on a
# hidden prompt: hold down Enter.
sudo apt install texlive-full
```

Notes:

* `kitty` from apt (0.32) works with these dotfiles. The bundle has a newer
  one, which is installed into `~/.local` and takes precedence.
* No longer installed: `htop` (btop), `screen` (tmux), `silversearcher-ag`
  (ripgrep, `rg`), `terminator` (kitty; install it again if you need it),
  `libtool-bin` (was for building vim/Neovim from source).

## 4. Git

```bash
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
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

## 5. Dotfiles

```bash
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/erik-linden/dotfiles.git   # offline: copy the folder over
cd dotfiles
./copy_to_home.py --dry-run   # see what would change
./copy_to_home.py
```

`copy_to_home.py` also makes scripts executable. Run it again after every
`git pull`. To go the other way, after changing files on the machine, run
`./copy_to_repo.py` and check `git diff`.

## 6. The offline bundle

On a Linux x86_64 machine **with internet** (with the dotfiles repo cloned):

```bash
scripts/fetch-offline-bundle.sh ~/dotfiles-bundle
```

This downloads Neovim, kitty, fzf, starship, tree-sitter, uv, pixi and the
JetBrains Mono Nerd Font. It also installs all Neovim plugins
(`nvim-data.tar.gz`), and downloads the source code of the treesitter parsers
(`parser-sources.tar.gz`). It needs no compiler, and works on any Linux.
Copy `~/dotfiles-bundle` to the target machine, then:

```bash
~/dotfiles-bundle/install-bundle.sh
```

Everything goes into `~/.local` (no sudo). The treesitter parsers are
compiled here, so they match this machine: that needs a C compiler
(`build-essential`, section 3) and the Neovim config already copied
(section 5). If that step fails, Neovim still works with simpler
highlighting; fix it and run the script again, or `:TSUpdate` in nvim.

Log out and in again so that `~/.local/bin` is on `PATH`. Run it again with
a newer bundle to update.

## 7. Font: JetBrains Mono Nerd Font

The bundle installs it to `~/.local/share/fonts`. Then:

* `gnome-tweaks` → Fonts → Monospace Text: *JetBrainsMono Nerd Font Regular 10*
* Antialiasing: Subpixel (RGB)

Check with `fc-list | grep -i jetbrains`.

## 8. Shell, terminal and desktop

### fish and starship

```bash
sudo apt install fish        # 3.7 in Ubuntu 24.04, new enough
# or newer: sudo apt-add-repository ppa:fish-shell/release-4 && sudo apt update && sudo apt install fish
```

**Don't make fish the login shell** (`chsh`). fish warns against it, because
it is not POSIX and programs that run the login shell can break. Instead,
kitty and tmux start fish themselves (see their configs), and bash stays
the login shell. `.bashrc` is kept usable for the times you end up in bash.

starship comes from the bundle. Online alternative:
`curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin`

Fish history from another machine:
`rsync -avh <old-machine>:.local/share/fish/fish_history ~/.local/share/fish/fish_history`

**zoxide** (apt) remembers the directories you `cd` into. `z dot` then
jumps to the most used directory matching "dot", and `zi` picks one with fzf.

### kitty

Installed from the bundle (or apt). The i3 config starts `kitty` directly.
`kitty +list-fonts | grep JetBrains` should list the font.

When ssh'ing to servers from kitty, `ssh` expands to `kitten ssh`, which
copies kitty's terminfo to the server (otherwise you get errors like
`'xterm-kitty': unknown terminal type`).

### i3, polybar, picom, rofi, dunst, lock screen

```bash
# Window manager, bar, compositor (only so GTK transparency isn't drawn black;
# no effects), launcher, notifications
sudo apt install i3 polybar picom rofi dunst
# Lock screen: i3lock, xss-lock (locks on suspend/idle), imagemagick (blurred screenshot)
sudo apt install i3lock xss-lock imagemagick
# dex: runs XDG autostart entries, feh: wallpaper, flameshot: screenshots,
# numlockx: numlock on at login, arandr: monitor setup GUI,
# pavucontrol: volume mixer (right-click the volume in the bar),
# copyq: clipboard history (Alt+y)
sudo apt install dex feh flameshot numlockx arandr pavucontrol copyq

# Laptop only: bluetooth, brightness keys/lid/suspend, and hiding the
# mouse cursor while typing
sudo apt install blueman xfce4-power-manager unclutter-xfixes
```

`xfce4-notifyd` competes with dunst for notifications. If notifications
look wrong, run `sudo apt remove xfce4-notifyd`.

Ubuntu 24.04 has i3 4.23, which is new enough. For the newest i3 use the
[sur5r repository](https://i3wm.org/docs/repositories.html).


**Machine profile.** `~/.config/i3/scripts/machine-profile.sh` detects
whether this is a `laptop`, a `desktop` or a `remote` (VM / remote
desktop) session. The autostart script (`scripts/autostart.sh`) and the bar use it:

| Profile | Extra programs | Bar modules |
|---------|----------------|-------------|
| laptop  | nm-applet, blueman, xfce4-power-manager, display daemon | wifi, ethernet, VPN, battery, volume |
| desktop | nm-applet, display daemon | ethernet, VPN, volume |
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
is a manual download; not worth it for now.)

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
Fonts → Scaling Factor instead.

**CopyQ** shows a tray icon in the bar; right-click it for settings, e.g.
the history size (default 200) or a dark theme (File → Preferences →
Appearance).

**Nautilus** may try to manage desktop icons under i3 and then crash things.
If that happens, disable GNOME's desktop icons (on 24.04 that is the
"Desktop Icons NG" extension, package `gnome-shell-extension-desktop-icons-ng`).

**Power settings (laptop):** run `xfce4-power-manager-settings`. Disable the
screen turning off and enable "Handle screen brightness keys".

**unclutter** (laptop; hides the mouse cursor while typing): set
`EXTRA_OPTS="-idle 1 -root --ignore-scrolling"` in `/etc/default/unclutter`.

### Optional: nicer lock screen (i3lock-color)

`lock.sh` works with plain `i3lock`, which gives a pixelated screenshot.
With [i3lock-color](https://github.com/Raymo111/i3lock-color) you get a
blurred screen, a clock and a colored ring. It has to be built from source.
`--mark-auto` marks the build dependencies as automatically installed, so a
later `sudo apt autoremove` cleans them up (packages you already had are
left as they were):

```bash
sudo apt install --mark-auto autoconf gcc make pkg-config libpam0g-dev \
    libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev \
    libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
    libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev \
    libxkbcommon-x11-dev libjpeg-dev libgif-dev
git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
sudo apt remove i3lock
./install-i3lock-color.sh
```

i3lock-color is not an apt package, so apt doesn't know it needs the
runtime libraries. They are normally kept anyway, since i3, polybar etc.
use them too, but after an `autoremove` check that it still starts:

```bash
ldd "$(command -v i3lock)" | grep "not found"   # should print nothing
```

To rebuild later (e.g. a new version), run the `apt install` line again.

## 9. Neovim

Ubuntu's Neovim (0.9) is too old. Install 0.11+ from the bundle. Then
either:

* **Online:** start `nvim`. It installs the plugins on the first start,
  then the treesitter parsers in the background.
* **Offline:** `install-bundle.sh` unpacks the plugins from the bundle to
  `~/.local/share/nvim`, and builds the treesitter parsers from the bundled
  sources (section 6). Neovim then builds from those sources instead of
  downloading, also for `:TSUpdate`.

The language servers are installed in section 10. Check everything with
`:checkhealth` inside nvim. `:Lazy` shows the plugins.

The old `~/.vimrc` still works for plain vim. To set it up anyway:
`curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`,
then `:PlugInstall` in vim.

## 10. Python: uv and pixi

* **uv** for Python projects, virtual environments and command line tools.
* **pixi** for projects that need conda-forge packages (CUDA, compiled libraries).
* **pip** refuses to install outside a virtual environment (`~/.config/pip/pip.conf`).
  Override once with `PIP_REQUIRE_VIRTUALENV=0 pip install ...`.
* **No conda.**

Both come from the bundle (work machine: set up the mirrors in section 1
first). Online alternative:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
curl -fsSL https://pixi.sh/install.sh | sh
```

Language servers for Neovim (from PyPI, works through the pip mirror):

```bash
uv tool install ruff
uv tool install basedpyright
```

A global IPython with the usual scientific packages, for quick scratch work
(replaces the conda base environment):

```bash
uv tool install ipython --with numpy --with scipy --with matplotlib \
    --with pandas --with scikit-learn --with sympy --with imageio --with rich
```

## 11. Chrome

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

**Switching an existing Chrome from `--password-store=basic`:** passwords
saved locally in the old store are not moved over. Before switching,
export them (Settings → Passwords → Settings → Export), or rely on
Chrome sync to bring them back.

## 12. Other software

**PyCharm:** use the JetBrains Toolbox.

**Rust:** download and run rustup (https://rustup.rs).

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
Offline: copy the binary over the same way. bazelisk then also needs the
Bazel releases themselves, either from a mirror
(`export BAZELISK_BASE_URL=https://<bazel-mirror>`) or by copying
`~/.cache/bazelisk` from a machine where the project has built once.

**Docker:** follow https://docs.docker.com/engine/install/ubuntu/ and
https://docs.docker.com/engine/install/linux-postinstall/
```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

**Fiji** (updates itself inside its folder, so it must be in your home)
```bash
mkdir -p ~/.local/opt && cd ~/.local/opt
wget https://downloads.imagej.net/fiji/latest/fiji-linux64.zip
unzip fiji-linux64.zip            # creates Fiji.app/
rm fiji-linux64.zip
# The launcher's name depends on the release
for launcher in fiji-linux-x64 ImageJ-linux64; do
    [ -x Fiji.app/$launcher ] && ln -sf ~/.local/opt/Fiji.app/$launcher ~/.local/bin/fiji
done
```

**p4merge** (merge tool in `.gitconfig`, for its 3-way view). Part of
P4V; find the newest release (`rYY.N`) on
https://www.perforce.com/downloads/helix-visual-client-p4v and set it below.
Run the same block again to update.
```bash
version=r25.1
wget https://www.perforce.com/downloads/perforce/$version/bin.linux26x86_64/p4v.tgz
tar -xzf p4v.tgz
rm -rf ~/.local/opt/p4merge
mkdir -p ~/.local/opt/p4merge
mv p4v-*/* ~/.local/opt/p4merge/
ln -sf ~/.local/opt/p4merge/bin/p4merge ~/.local/bin/p4merge
rm -r p4v.tgz p4v-*
```
