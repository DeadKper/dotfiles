#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if type lsd &>/dev/null; then
	alias ls='lsd'
else
	alias ls='ls --color=auto'
fi

if type starship &>/dev/null; then
	eval "$(starship init bash)"
fi

if type zoxide &>/dev/null; then
	eval "$(zoxide init bash)"
fi

eval "$(fzf --bash)"

alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias grep='grep --color=auto'
