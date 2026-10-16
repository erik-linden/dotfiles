# Rust (cargo, rustc), if rustup is installed. rustup's installer looks for
# `source "$HOME/.cargo/env.fish"` and leaves this file alone when it's there.
test -f "$HOME/.cargo/env.fish"; and source "$HOME/.cargo/env.fish"
