which nvim &>/dev/null && alias vim=nvim

if which lsd &>/dev/null; then
    alias ls=lsd
    alias lt="lsd --tree"
    alias tree="lsd --tree"
else
    alias ls="ls --color=auto"
fi

alias l="ls -l"
alias ll="ls -l"
alias la="ls -A"
alias lla="ls -lA"

if which fzf &>/dev/null; then
    alias cf='__path="$(find . -mindepth 1 -type d | sed "s,^\./,," | sort -rV | fzf)"; test -n "$__path" && cd "$__path"'
    alias zf='__path="$(find . -mindepth 1 -type d | sed "s,^\./,," | sort -rV | fzf)"; test -n "$__path" && z "$__path"'
fi

alias pkill="pkill -i"
alias pgrep="pgrep -i"
