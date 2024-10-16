if type nvim &>/dev/null; then
  alias vim=nvim
fi

if type lsd &>/dev/null; then
  alias ls=lsd
  alias tree="lsd --tree"
fi
