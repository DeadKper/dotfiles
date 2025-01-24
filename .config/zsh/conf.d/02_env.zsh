typeset -TUx PATH path
path+=(/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin)
path=("$HOME/.local/scripts" "$HOME/.local/bin" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "${path[@]}")

if which manpath &>/dev/null; then
    MANPATH="$(manpath 2>/dev/null)"
fi

typeset -TUx MANPATH manpath
manpath=("${(@f)$(find "$ZIM_HOME" -type d -name man)}" "${manpath[@]}")

export EDITOR=nvim
export VISUAL=nvim
which nvim &>/dev/null && export MANPAGER='nvim +Man!'
export YDOTOOL_SOCKET="${XDG_STATE_HOME:=$HOME/.local/state}/ydotool.socket"

export TIMEFMT="
________________________________________
Executed in %*E CPU %P
   usr time %*U
   sys time %*S"

unset LS_COLORS
unset GREP_COLOR
unset GREP_COLORS
