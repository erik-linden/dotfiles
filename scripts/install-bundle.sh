#!/usr/bin/env bash
# Install a folder made by fetch-offline-bundle.sh into ~/.local (no sudo).
# Each part is optional: whatever files are in the folder get installed.
#
# Usage: ./install-bundle.sh [bundle-dir]   (default: the folder of this script)
#
# Same rule as everything else installed by hand (see docs/SETUP.md): the
# place the program's own installer uses, otherwise single-file programs in
# ~/.local/bin and folders in ~/.local/opt/<name> with a link in ~/.local/bin.
#
# Installs to:
#   ~/.local/kitty.app                      kitty (where kitty's installer puts it)
#   ~/.pixi/bin                             pixi (where pixi's installer puts it)
#   ~/.cargo, ~/.rustup                     rustup (where its installer puts it),
#                                           with the toolchain linked as "bundle"
#   ~/.local/opt/rust                       the Rust toolchain itself
#   ~/.cargo/bin/i3wsr                      i3wsr, built here (where `cargo install`
#                                           puts it)
#   ~/.local/opt/nvim                       Neovim
#   ~/.local/opt/Fiji                       Fiji
#   ~/.local/opt/p4merge                    P4V, with p4merge
#   ~/.local/bin                            links to nvim, kitty, kitten, fiji,
#                                           p4merge, and the single-file fzf,
#                                           starship, tree-sitter, uv, uvx
#   ~/.local/share/fonts/JetBrainsMono      font
#   ~/.local/share/nvim                     Neovim plugins, parser sources, and
#                                           the parsers, built here (needs a
#                                           C compiler and ~/.config/nvim)

set -euo pipefail

bundle=$(cd "${1:-$(dirname "$0")}" && pwd)
bin="$HOME/.local/bin"
mkdir -p "$bin" "$HOME/.local/opt" "$HOME/.local/share/applications"
cd "$bundle"

have() { [ -f "$1" ] && echo "==> $1"; }

if have nvim-linux-x86_64.tar.gz; then
    rm -rf "$HOME/.local/opt/nvim"
    mkdir -p "$HOME/.local/opt/nvim"
    tar xzf nvim-linux-x86_64.tar.gz --strip-components=1 -C "$HOME/.local/opt/nvim"
    ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$bin/nvim"
fi

if have kitty-x86_64.txz; then
    # Where kitty's own installer puts it
    kitty="$HOME/.local/kitty.app"
    rm -rf "$kitty"
    mkdir -p "$kitty"
    tar xJf kitty-x86_64.txz -C "$kitty"
    ln -sf "$kitty/bin/kitty" "$kitty/bin/kitten" "$bin/"
    # Desktop entries, so rofi finds kitty
    cp "$kitty/share/applications/"kitty*.desktop "$HOME/.local/share/applications/"
    sed -i "s|Icon=kitty|Icon=$kitty/share/icons/hicolor/256x256/apps/kitty.png|g" \
        "$HOME/.local/share/applications/"kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$kitty/bin/kitty|g" \
        "$HOME/.local/share/applications/"kitty*.desktop
fi

if have fzf-linux_amd64.tar.gz; then
    tar xzf fzf-linux_amd64.tar.gz -C "$bin" fzf
fi

if have starship.tar.gz; then
    tar xzf starship.tar.gz -C "$bin" starship
fi

if have tree-sitter-linux-x64.gz; then
    # Used by nvim to build the treesitter parsers (below, and :TSUpdate)
    gunzip -c tree-sitter-linux-x64.gz >"$bin/tree-sitter"
    chmod +x "$bin/tree-sitter"
fi

if have uv.tar.gz; then
    tar xzf uv.tar.gz --strip-components=1 -C "$bin"
fi

if have pixi.tar.gz; then
    # Where pixi's own installer puts it (on PATH via config.fish / .bashrc)
    mkdir -p "$HOME/.pixi/bin"
    tar xzf pixi.tar.gz -C "$HOME/.pixi/bin" pixi
fi

if have fiji-linux64.zip; then
    # Fiji updates itself inside its folder (plugins too), so keep the old
    # one, as Fiji.bak (replacing the backup from the time before)
    fiji="$HOME/.local/opt/Fiji"
    if [ -d "$fiji" ]; then
        echo "    Moving the old $fiji to $fiji.bak"
        rm -rf "$fiji.bak"
        mv "$fiji" "$fiji.bak"
    fi
    if command -v unzip >/dev/null; then
        # (creates the folder Fiji/)
        unzip -q fiji-linux64.zip -d "$HOME/.local/opt"
        ln -sf "$fiji/fiji-linux-x64" "$bin/fiji"
    else
        echo "    unzip missing (sudo apt install unzip), Fiji not installed."
    fi
fi

if have p4v.tgz; then
    # Only p4merge (the merge tool in .gitconfig) gets a link
    rm -rf "$HOME/.local/opt/p4merge"
    mkdir -p "$HOME/.local/opt/p4merge"
    tar xzf p4v.tgz --strip-components=1 -C "$HOME/.local/opt/p4merge"
    ln -sf "$HOME/.local/opt/p4merge/bin/p4merge" "$bin/p4merge"
fi

if have JetBrainsMono.tar.xz; then
    fonts="$HOME/.local/share/fonts/JetBrainsMono"
    mkdir -p "$fonts"
    tar xJf JetBrainsMono.tar.xz -C "$fonts"
    fc-cache -f "$fonts"
fi

if have nvim-data.tar.gz; then
    # Keep the old one as nvim.bak (replacing the backup from the time before)
    data="$HOME/.local/share/nvim"
    if [ -d "$data" ]; then
        echo "    Moving the old $data to $data.bak"
        rm -rf "$data.bak"
        mv "$data" "$data.bak"
    fi
    tar xzf nvim-data.tar.gz -C "$HOME/.local/share"
fi

export PATH="$bin:$HOME/.pixi/bin:$HOME/.cargo/bin:$PATH"

# Rust: rustup can't download toolchains here, so the toolchain from Rust's
# standalone installer goes to ~/.local/opt/rust, and rustup is told to use
# it (`rustup toolchain link`). rustup itself is installed as usual, so
# ~/.cargo/bin (rustc, cargo, and what `cargo install` installs) gets on
# PATH the usual way: .profile, .bashrc and conf.d/rustup.fish load
# ~/.cargo/env. Running this again replaces the toolchain with the bundle's.
if have rust.tar.xz; then
    work=$(mktemp -d)
    tar xJf rust.tar.xz -C "$work" --strip-components=1
    rm -rf "$HOME/.local/opt/rust"
    # The parts rustup installs by default (its "default" profile: rustc,
    # cargo, the standard library, docs for `rustup doc`, rustfmt, clippy)
    # plus rust-analyzer; the rest is large and rarely needed.
    "$work/install.sh" --prefix="$HOME/.local/opt/rust" --disable-ldconfig \
        --without=rust-docs-json-preview,llvm-tools-preview,llvm-bitcode-linker-preview,rust-analysis-x86_64-unknown-linux-gnu \
        >/dev/null

    if ! command -v rustup >/dev/null && [ -f rustup-init ]; then
        # --no-modify-path: the dotfiles already load ~/.cargo/env
        cp rustup-init "$work/"
        chmod +x "$work/rustup-init"
        "$work/rustup-init" -y --quiet --no-modify-path --default-toolchain none
    fi
    rm -rf "$work"
    if command -v rustup >/dev/null; then
        rustup toolchain link bundle "$HOME/.local/opt/rust"
        rustup default bundle
    else
        echo "    rustup missing (no rustup-init in the bundle), Rust installed but not on PATH."
    fi
fi

# i3wsr: built here from the bundled source code (with the vendored source
# of everything it uses, so cargo needs no internet). Same result as
# `cargo install i3wsr`: the program goes to ~/.cargo/bin.
if have i3wsr-src.tar.gz; then
    if command -v cargo >/dev/null && command -v cc >/dev/null; then
        work=$(mktemp -d)
        tar xzf i3wsr-src.tar.gz -C "$work"
        # (from inside the folder, so cargo reads its .cargo/config.toml)
        (cd "$work/i3wsr" && cargo install --quiet --offline --locked --path .) \
            || echo "    Building i3wsr failed."
        rm -rf "$work"
    else
        echo "    cargo or a C compiler (cc, for linking) missing, i3wsr not built."
    fi
fi

# Treesitter parsers: build them here from the bundled source code, so they
# match this machine. The nvim config (plugins/treesitter.lua) finds the
# sources in ~/.local/share/nvim/parser-sources. If building fails, nvim
# still works, with simpler highlighting; retry later with :TSUpdate.
if have parser-sources.tar.gz; then
    rm -rf "$HOME/.local/share/nvim/parser-sources"
    mkdir -p "$HOME/.local/share/nvim"
    tar xzf parser-sources.tar.gz -C "$HOME/.local/share/nvim"

    if ! command -v cc >/dev/null; then
        echo "    No C compiler (cc), parsers not built. Install build-essential, then run this again."
    elif ! command -v tree-sitter >/dev/null || ! command -v nvim >/dev/null; then
        echo "    tree-sitter or nvim missing, parsers not built."
    elif [ ! -f "$HOME/.config/nvim/init.lua" ]; then
        echo "    No nvim config yet, parsers not built. Run copy_to_home.py, then this again."
    else
        # (The nvim config limits the compiler's memory use, see
        # plugins/treesitter.lua)
        echo "    Building parsers (takes a minute)..."
        nvim --headless \
            "+lua require('nvim-treesitter').install(require('config.parsers')):wait(600000)" +qa \
            || echo "    Some parsers failed to build; see :checkhealth nvim-treesitter"
        echo
        echo "    $(ls "$HOME/.local/share/nvim/site/parser/"*.so 2>/dev/null | wc -l) parsers installed"
    fi
fi

echo
echo "Done. Make sure $bin is on PATH (log out and in again if it was just created)."
for cmd in nvim kitty fzf starship tree-sitter uv pixi rustc cargo i3wsr; do
    if command -v "$cmd" >/dev/null; then
        printf '  %-12s %s\n' "$cmd" "$("$cmd" --version 2>/dev/null | head -n1)"
    fi
done
# (GUI programs: only check that they are there)
for cmd in fiji p4merge; do
    if command -v "$cmd" >/dev/null; then
        printf '  %-12s %s\n' "$cmd" "$(command -v "$cmd")"
    fi
done
