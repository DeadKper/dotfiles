if not set -q RUSTUP_HOME
  set -xg RUSTUP_HOME "$HOME/.local/share/rust/rustup"
  set -xg CARGO_HOME "$HOME/.local/share/rust/cargo"
  add_path PATH "$CARGO_HOME/bin"
end