if type nvim &>/dev/null; then
  export EDITOR=nvim
  export VISUAL=nvim
elif type vim &>/dev/null; then
  export EDITOR=vim
  export VISUAL=vim
elif type vi &>/dev/null; then
  export EDITOR=vi
  export VISUAL=vi
fi
