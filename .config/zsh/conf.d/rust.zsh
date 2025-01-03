if [[ -o login ]] && test -z "${ZSH_LOGIN+1}"; then
    export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rust/rustup"
    export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rust/cargo"
    export PATH="$CARGO_HOME/bin:$PATH"
fi
