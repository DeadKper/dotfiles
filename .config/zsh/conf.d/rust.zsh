local XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export RUSTUP_HOME="$XDG_DATA_HOME/rust/rustup"
export CARGO_HOME="$XDG_DATA_HOME/rust/cargo"

add_path PATH "$CARGO_HOME/bin"
