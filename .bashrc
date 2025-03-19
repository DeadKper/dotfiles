#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if type lsd &>/dev/null; then
	alias ls='lsd'
	alias tree='lsd --tree'
else
	alias ls='ls --color=auto'
fi

if type starship &>/dev/null; then
	eval "$(starship init bash)"
fi

if type zoxide &>/dev/null; then
	eval "$(zoxide init bash)"
fi

if which fzf &>/dev/null; then
	eval "$(fzf --bash)"
fi

alias l='ls -l'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias grep='grep --color=auto'

which nvim &>/dev/null && alias vim=nvim

if test -f ~/.local/share/blesh/ble.sh; then
	source ~/.local/share/blesh/ble.sh
	if type starship &>/dev/null; then
		bleopt prompt_ps1_final='$(starship module character)'
		bleopt prompt_rps1_final='$(starship module time | xargs -d \\n -I {} echo "{} ")'
	fi
fi
. "/home/missael/.local/share/rust/cargo/env"
