#!/usr/bin/env bash
# Download the tools that are missing or too old in Ubuntu 24.04 apt into one
# folder. Run this on a Linux x86_64 machine with internet, move the folder to
# the offline machine, and run install-bundle.sh there.
#
# For an online install, run both scripts on the same machine.
#
# Usage: scripts/fetch-offline-bundle.sh [output-dir]   (default ~/dotfiles-bundle)
#
# Needs: curl, tar, git. (No compiler: the treesitter parsers and i3wsr are
# only downloaded here, as source code, and built by install-bundle.sh on the
# target machine.)

set -uo pipefail

# p4merge (part of P4V): the newest release (rYY.N) is listed on
# https://www.perforce.com/downloads/helix-visual-client-p4v
p4v_version=r26.3

out=${1:-$HOME/dotfiles-bundle}
repo=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$out"
cd "$out" || exit 1
failed=()

# URL of the newest release asset of a GitHub repo whose name matches a regex
gh_latest() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
        | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | grep -E "$2" | head -n1
}

# fetch URL FILENAME
fetch() {
    echo "==> $2"
    if [ -z "$1" ] || ! curl -fL --retry 3 --progress-bar -o "$2" "$1"; then
        echo "    FAILED: $2"
        failed+=("$2")
    fi
}

gh=https://github.com
fetch "$gh/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" nvim-linux-x86_64.tar.gz
fetch "$(gh_latest kovidgoyal/kitty 'kitty-[0-9.]+-x86_64\.txz$')" kitty-x86_64.txz
fetch "$(gh_latest junegunn/fzf 'linux_amd64\.tar\.gz$')" fzf-linux_amd64.tar.gz
fetch "$gh/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz" starship.tar.gz
fetch "$gh/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz" tree-sitter-linux-x64.gz
fetch "$gh/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz" uv.tar.gz
fetch "$gh/prefix-dev/pixi/releases/latest/download/pixi-x86_64-unknown-linux-musl.tar.gz" pixi.tar.gz
fetch "$gh/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" JetBrainsMono.tar.xz
fetch https://downloads.imagej.net/fiji/latest/fiji-latest-linux64-jdk.zip fiji-linux64.zip
fetch "https://www.perforce.com/downloads/perforce/$p4v_version/bin.linux26x86_64/p4v.tgz" p4v.tgz

# --- Rust ---------------------------------------------------------------------
# rustup can't download toolchains without internet, so the bundle has
# rustup itself (rustup-init) and Rust's standalone installer for the newest
# stable version. install-bundle.sh installs the toolchain and tells rustup
# to use it.
rust_version=$(curl -fsSL https://static.rust-lang.org/dist/channel-rust-stable.toml \
    | grep -A1 '^\[pkg\.rust\]$' | sed -n 's/^version = "\([0-9.]*\) .*/\1/p')
echo "    Rust ${rust_version:-(version not found)}"
fetch "${rust_version:+https://static.rust-lang.org/dist/rust-$rust_version-x86_64-unknown-linux-gnu.tar.xz}" rust.tar.xz
fetch https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init rustup-init

# --- i3wsr (names workspaces after their windows) -----------------------------
# Only released as source code (`cargo install i3wsr`). Download the newest
# release and the source code of everything it uses (`cargo vendor`), so
# install-bundle.sh can build it without internet, with the bundled Rust.
# This uses the cargo from rust.tar.xz above; nothing is compiled here.
if [ -f rust.tar.xz ]; then
    echo "==> i3wsr-src.tar.gz"
    work=$(mktemp -d)
    tag=$(curl -fsSL https://api.github.com/repos/roosta/i3wsr/releases/latest \
        | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
    tar xJf rust.tar.xz -C "$work" --wildcards '*/cargo/bin/cargo'
    cargo=$(echo "$work"/rust-*/cargo/bin/cargo)
    if [ -n "$tag" ] \
        && git clone --quiet --depth 1 --branch "$tag" "$gh/roosta/i3wsr.git" "$work/i3wsr" \
        && mkdir -p "$work/i3wsr/.cargo" \
        && (cd "$work/i3wsr" && CARGO_HOME="$work/cargo-home" \
            "$cargo" vendor --locked vendor >.cargo/config.toml); then
        # (.cargo/config.toml now tells cargo to use the vendor folder)
        rm -rf "$work/i3wsr/.git"
        tar czf i3wsr-src.tar.gz -C "$work" i3wsr
        echo "    i3wsr $tag"
    else
        echo "    FAILED: i3wsr-src.tar.gz"
        failed+=(i3wsr-src.tar.gz)
    fi
    rm -rf "$work"
fi

# --- Neovim plugins and treesitter parser sources ----------------------------
# Runs the downloaded nvim with the repo's config and a separate data dir, so
# your own ~/.local/share/nvim is not touched.
# The parsers are only *downloaded* here (source code, at the versions
# nvim-treesitter pins). install-bundle.sh compiles them on the target
# machine, so they always match its system.
if [ -f nvim-linux-x86_64.tar.gz ]; then
    echo "==> Neovim plugins"
    work=$(mktemp -d)
    tar xzf nvim-linux-x86_64.tar.gz -C "$work"
    nvim="$work/nvim-linux-x86_64/bin/nvim"

    # (tree-sitter is deliberately not on PATH here, so nvim doesn't try to
    # build parsers on this machine)
    export XDG_CONFIG_HOME="$repo/dotfiles/.config"
    export XDG_DATA_HOME="$work/data"
    export XDG_STATE_HOME="$work/state"
    export XDG_CACHE_HOME="$work/cache"

    # Install the versions in lazy-lock.json if there is one, otherwise the newest
    if [ -f "$XDG_CONFIG_HOME/nvim/lazy-lock.json" ]; then
        "$nvim" --headless "+Lazy! restore" +qa
    else
        "$nvim" --headless "+Lazy! sync" +qa
    fi
    # blink.cmp downloads its prebuilt fuzzy matcher when it is first loaded
    "$nvim" --headless "+Lazy! load blink.cmp" "+lua vim.wait(30000)" +qa

    tar czf nvim-data.tar.gz -C "$XDG_DATA_HOME" nvim || failed+=(nvim-data.tar.gz)

    echo "==> Treesitter parser sources"
    PARSER_LIST="$work/parsers.txt" "$nvim" --headless \
        "+luafile $repo/scripts/list-parser-sources.lua" +qa
    rm -rf parser-sources
    mkdir -p parser-sources
    while read -r lang url revision; do
        echo "    $lang"
        dir="parser-sources/$lang"
        if git clone --quiet --filter=blob:none "$url" "$dir" \
            && git -C "$dir" -c advice.detachedHead=false checkout --quiet "$revision"; then
            rm -rf "$dir/.git"
        else
            echo "    FAILED: parser $lang"
            failed+=("parser-$lang")
            rm -rf "$dir"
        fi
    done <"$work/parsers.txt"
    tar czf parser-sources.tar.gz parser-sources && rm -rf parser-sources

    unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
    rm -rf "$work"
    echo
    echo "    If lazy-lock.json was created/updated in the repo, commit it, so"
    echo "    the next bundle gets the same plugin versions."
fi

cp "$repo/scripts/install-bundle.sh" .

echo
echo "Bundle in $out:"
ls -lh "$out"
if [ ${#failed[@]} -gt 0 ]; then
    echo
    echo "FAILED: ${failed[*]}"
    exit 1
fi
