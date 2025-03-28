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

export LIBVIRT_DEFAULT_URI=qemu:///system

if test -f ~/.local/share/blesh/ble.sh; then
    source ~/.local/share/blesh/ble.sh
    if type starship &>/dev/null; then
        bleopt prompt_ps1_final='$(starship module character)'
        bleopt prompt_rps1_final='$(starship module time | xargs -d \\n -I {} echo "{} ")'
    fi
fi

sudo() {
	# trap "trap - return; set +x" return
	# set -x
	local args=()
	while test "$#" -gt 0; do
		case "$1" in
			--)
				args+=("$1")
				break
				;;
			-C|-D|-g|-p|-R|-T|-U|-u)
				test "$#" -lt 2 && { env sudo "${args[@]}" "$@"; return $?; }
				args+=("$1" "$2")
				shift 2
				;;
			-h|--help|-V|--version|-l|--list|-K|--remove-timestamp)
				env sudo "${args[@]}" "$@"
				return $?
				;;
			-*)
				args+=("$1")
				shift
				;;
			*)
				break
				;;
		esac
		[[ $- == *x* ]] && sleep 0.25
	done
	local env_args=()
	if test "$(echo | env sudo -n "${args[@]}" echo y 2>&1)" == "$(echo | env sudo -n -E --preserve-env=PATH "${args[@]}" echo y 2>&1)"; then
		env_args=(--preserve-env=PATH -E)
	fi
	if [ -t 0 ] && which epmcli &>/dev/null && which expect &>/dev/null; then
		local message='epm justification'

		expect -f <(cat <<EOF
set timeout 1
$([[ $- == *x* ]] && echo exp_internal 1)
log_user $([[ $- == *x* ]] && echo 1 || echo 0)
eval spawn -noecho env sudo \$argv
expect {
	{Please provide justification:} {
		send -- "${message}\\r"
		expect "${message}"
		log_user 1
		interact
	}
	default {
		send "\\r"
		expect -- "\\r"
		log_user 1
		interact
	}
	eof {
	}
}
catch wait result
exit [lindex \$result 3]
EOF
) -- "${args[@]}" "$@"
	else
		env sudo "${env_args[@]}" "${args[@]}" "$@"
	fi
}

export -f sudo
alias sudo='sudo '

[[ -f ~/.local/share/rust/cargo/env ]] && source ~/.local/share/rust/cargo/env
