which nvim &>/dev/null && alias vim=nvim

if which lsd &>/dev/null; then
    alias ls=lsd
    alias lt="lsd --tree"
    alias tree="lsd --tree"
else
    alias ls="ls --color=auto"
fi

if command -v trash &>/dev/null; then
    alias rm=trash
fi

alias l="ls -l"
alias ll="ls -l"
alias la="ls -A"
alias lla="ls -lA"

if command -v rg &>/dev/null; then
    alias cat="rg '' -N --colors=match:none "
fi
