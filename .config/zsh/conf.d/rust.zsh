export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rust/rustup"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rust/cargo"
path=("$CARGO_HOME/bin" "${path[@]}")
