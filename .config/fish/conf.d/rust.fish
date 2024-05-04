set -x RUSTUP_HOME "$HOME/.local/share/rust/rustup"
set -x CARGO_HOME "$HOME/.local/share/rust/cargo"

set -x --path PATH $PATH
add-path PATH "$CARGO_HOME/bin"
