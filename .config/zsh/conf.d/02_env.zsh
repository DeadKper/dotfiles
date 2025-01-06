if [[ -o login ]]; then
    typeset -TUx PATH path
    path+=(/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin)
    path=("$HOME/.local/scripts" "$HOME/.local/bin" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "${path[@]}")

    if which manpath &>/dev/null; then
        MANPATH="$(manpath 2>/dev/null)"
    fi

    typeset -TUx MANPATH manpath
    manpath=("${(@f)$(find "$ZIM_HOME" -type d -name man)}" "${manpath[@]}")
fi

export EDITOR=nvim
export VISUAL=nvim
which nvim &>/dev/null && export MANPAGER='nvim +Man!'
export YDOTOOL_SOCKET="${XDG_STATE_HOME:=$HOME/.local/state}/ydotool.socket"

export ZSH_AUTOSUGGEST_STRATEGY=(abbreviations $ZSH_AUTOSUGGEST_STRATEGY)

export TIMEFMT="$(cat <<EOF

________________________________________
Executed in %*E CPU %P
   usr time %*U
   sys time %*S
EOF
)"

unset LS_COLORS
unset GREP_COLOR
unset GREP_COLORS
