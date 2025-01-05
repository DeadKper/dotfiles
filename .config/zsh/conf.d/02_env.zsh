typeset -U path PATH
path+=(/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin)
path=("$HOME/.local/scripts" "$HOME/.local/bin" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "${path[@]}")

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

if which manpath &>/dev/null; then
    unset MANPATH
    export MANPATH="$(find "$ZIM_HOME" -type d -name man | xargs -r -d \\n -I {} echo -n {}:)$(manpath)"
    typeset -U manpath MANPATH
fi

unset LS_COLORS
unset GREP_COLOR
unset GREP_COLORS
