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
#   ~/.local/opt/nvim                       Neovim
#   ~/.local/bin                            links to nvim, kitty, kitten, and the
#                                           single-file fzf, starship,
#                                           tree-sitter, uv, uvx
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

if have JetBrainsMono.tar.xz; then
    fonts="$HOME/.local/share/fonts/JetBrainsMono"
    mkdir -p "$fonts"
    tar xJf JetBrainsMono.tar.xz -C "$fonts"
    fc-cache -f "$fonts"
fi

if have nvim-data.tar.gz; then
    data="$HOME/.local/share/nvim"
    if [ -d "$data" ]; then
        backup="$data.bak.$(date +%Y%m%d-%H%M%S)"
        echo "    Moving the old $data to $backup"
        mv "$data" "$backup"
    fi
    tar xzf nvim-data.tar.gz -C "$HOME/.local/share"
fi

export PATH="$bin:$HOME/.pixi/bin:$PATH"

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
        # -Wno-uninitialized: with -Wall (added by tree-sitter build), gcc
        # needs ~4.7 GB of RAM for the gitcommit parser alone, enough to
        # freeze a small VM. Without that warning it needs ~0.5 GB.
        echo "    Building parsers (takes a minute)..."
        CFLAGS="${CFLAGS:-} -Wno-uninitialized" nvim --headless \
            "+lua require('nvim-treesitter').install(require('config.parsers')):wait(600000)" +qa \
            || echo "    Some parsers failed to build; see :checkhealth nvim-treesitter"
        echo
        echo "    $(ls "$HOME/.local/share/nvim/site/parser/"*.so 2>/dev/null | wc -l) parsers installed"
    fi
fi

echo
echo "Done. Make sure $bin is on PATH (log out and in again if it was just created)."
for cmd in nvim kitty fzf starship tree-sitter uv pixi; do
    if command -v "$cmd" >/dev/null; then
        printf '  %-12s %s\n' "$cmd" "$("$cmd" --version 2>/dev/null | head -n1)"
    fi
done
