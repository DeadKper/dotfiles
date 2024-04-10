set -x RUSTUP_HOME "$HOME/.local/share/rust/rustup"
set -x CARGO_HOME "$HOME/.local/share/rust/cargo"

if test -d "$CARGO_HOME/bin"
  add-path PATH "$CARGO_HOME/bin"
end
