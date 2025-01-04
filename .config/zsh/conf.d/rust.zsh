if [[ -o login ]]; then
    export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rust/rustup"
    export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rust/cargo"
    export PATH="$CARGO_HOME/bin:$PATH"
fi
