local RUST_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rust"
export RUSTUP_HOME="$RUST_HOME/rustup"
export CARGO_HOME="$RUST_HOME/cargo"
[[ -f "$RUST_HOME/cargo/env" ]] && source "$RUST_HOME/cargo/env"
