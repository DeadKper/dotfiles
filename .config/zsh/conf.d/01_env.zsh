if [[ -o login ]] && test -z "${ZSH_LOGIN+1}"; then
    export EDITOR=nvim
    export VISUAL=nvim
    which nvim &>/dev/null && export MANPAGER='nvim +Man!'
    export YDOTOOL_SOCKET="$HOME/.local/state/ydotool.socket"

    if which manpath &>/dev/null && test -z "${MANPATH+1}"; then
        export MANPATH="$(manpath)"
        typeset -U path MANPATH
    fi
    typeset -U path PATH
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    export GREP_COLORS='ms=01;31'
fi
