if not set -q RUSTUP_HOME
  set -xg RUSTUP_HOME "$HOME/.local/share/rust/rustup"
  set -xg CARGO_HOME "$HOME/.local/share/rust/cargo"
  fish_add_path "$CARGO_HOME/bin"
end
